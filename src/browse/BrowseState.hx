package browse;

import AppUtil.*;
import CatGenerator;

import browse.Carousel;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

import openfl.display.BitmapData;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

class BrowseState extends FlxTransitionableState
{
	public static inline var TILE_SIZE:Int = 16;

	public var textBox:FlxSprite;
	public var infoText:FlxTypeText;
	public var ctrlText:FlxText;
	public var textFormat:FlxTextFormatMarkerPair;

	public var progressBar:FlxBar;
	public var progress(get, never):Float;

	public var carousel:Carousel;
	public var generator:CatGenerator;
	public var photoCount:Int = 16;

	public var downloadBox:FlxSprite;

	public var isolated:Bool = false;

	var photoCache:Array<CarouselPhoto> = [];

	public function new()
	{
		super();
	}

	override public function create():Void
	{
		progressBar = new FlxBar(0, 0, null, TILE_SIZE * 16, TILE_SIZE, this, "progress", 0, 1);
		progressBar.createFilledBar(FlxColor.WHITE, SOFT_BLACK);
		progressBar.filledCallback = allCatsGenerated;
		progressBar.screenCenter();

		carousel = new Carousel(photoCount, FlxG.width * 0.5, FlxG.height * 0.5 - 120, 250, 80);

		FlxG.camera.bgColor = SOFT_WHITE;
		add(progressBar);

		generator = new CatGenerator();
		generator.onCatGenerated.add(catGenerated);
		generator.requestCat(photoCount);
	}

	function renderUI():Void
	{
		carousel.frontPhotoChanged.add((_) -> updateDescription());

		textFormat = AppUtil.getIceTextFormat();
		
		textBox = new FlxSprite(32, TILE_SIZE * 22).makeGraphic(FlxG.width - 64, TILE_SIZE * 8, SOFT_NAVY);
		infoText = new FlxTypeText(textBox.x + 4, textBox.y + 4, Std.int(textBox.width) - 8, "Neko");
		ctrlText = new FlxText();
		ctrlText.applyMarkup("Skip text: @SPACE@ | Select photo: @UP@ | Deselect photo: @DOWN@ | Spin carousel: @LEFT@, @RIGHT@, or @Scroll wheel@", [textFormat]);
		ctrlText.alignment = CENTER;
		ctrlText.screenCenter(X);
		ctrlText.y = FlxG.height - ctrlText.height;

		downloadBox = new FlxSprite(FlxG.width, 16).makeGraphic(TILE_SIZE * 16, TILE_SIZE * 20, SOFT_NAVY);

		remove(progressBar);
		FlxG.camera.bgColor = FlxColor.WHITE;

		add(carousel);
		add(textBox);
		add(infoText);
		add(ctrlText);
		add(downloadBox);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
		FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);

		transitionIn();
	}

	function catGenerated(data:CatData):Void
	{
		var photo = new CarouselPhoto();
		photo.antialiasing = true;
		photo.meta = data;		
		photo.loadGraphic(data.image);
		photoCache.push(photo);

		if(photoCache.length == photoCount)
			allCatsGenerated();
	}

	function allCatsGenerated():Void
	{
		renderUI();

		for(i in 0...photoCount)
		{
			var photo = photoCache.shift();
			var point = carousel.positions[i];
			point.sprite = photo;
			
			var scale = photo.calculateScale(point.size);
			photo.x = -photo.scaledWidth;
			photo.y = -photo.scaledHeight;
			photo.scale.set(scale, scale);
			photo.updateHitbox();

			FlxTween.tween(photo, {
				x: carousel.centerX + point.x - photo.scaledWidth * 0.5, 
				y: carousel.centerY + point.y - photo.scaledHeight * 0.5
			}, 0.3, {startDelay: 0.8 + i / 20, ease: FlxEase.backOut});

			carousel.add(photo);
		}

		carousel.sortByDepth();
		updateDescription();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	function keyPressed(event:KeyboardEvent):Void
	{
		switch(event.keyCode)
		{
			case FlxKey.LEFT:
				spinCarousel(COUNTER_CLOCKWISE);
			case FlxKey.RIGHT:
				spinCarousel(CLOCKWISE);

			case FlxKey.ENTER:
				isolatePhoto();

			case FlxKey.ESCAPE:
			{
				if(isolated)
					deisolatePhoto();
				else
					FlxG.switchState(MainMenuState.new);
			}
		}
	}

	function mouseWheel(event:MouseEvent):Void
	{
		if(isolated) return;

		if(event.delta > 0)
			spinCarousel(COUNTER_CLOCKWISE);
		else
			spinCarousel(CLOCKWISE);
	}

	function spinCarousel(direction:WheelDirection):Void
	{
		if(carousel.length != photoCount) return;

		if(isolated)
			isolated = false;

		infoText.erase();
		infoText.skip();

		carousel.spin(direction);
	}

	function updateDescription():Void
	{
		if(carousel.length != photoCount) return;

		var photo = carousel.positions[0].sprite;
		var meta:CatData = cast photo.meta;
		if(meta.breeds != null && meta.breeds.length > 0)
		{
			var cat = meta.breeds[0].name;
			var origin = meta.breeds[0].origin;
			var temperament = meta.breeds[0].temperament;
			var description = meta.breeds[0].description;

			var displayText = '@Cat name:@ ${cat}\n\n' 
				+ '@Origin:@ ${origin}\n\n'
				+ '@Temperament:@ ${temperament}\n\n'
				+ '@Description:@ ${description}';

			infoText.applyMarkup(displayText, [textFormat]);
		}
		else if(StringTools.endsWith(meta.url, ".jpg"))
		{
			infoText.resetText("No description available :/");
		}
		else
		{
			infoText.resetText("Failed to load image :O");
		}

		infoText.start(0.01, true, false, [SPACE]);
	}

	function isolatePhoto():Void
	{
		if(isolated || carousel.length != photoCount) return;

		isolated = true;

		for(i in 0...carousel.length)
		{
			var item = carousel.positions[i];
			var photo = item.sprite;
			if(photo.transitionTween != null)
				photo.transitionTween.cancel();

			if(i == 0)
			{
				var scale = 1.0;
				if(photo.orientation == LANDSCAPE)
					scale = photo.calculateScale(textBox.width - downloadBox.width - 32);
				else
					scale = photo.calculateScale(downloadBox.height);

				photo.transitionTween = FlxTween.tween(photo, {
					x: 32 + (textBox.width - downloadBox.width) * 0.5 - photo.scaledWidth * 0.5, 
					y: downloadBox.y + downloadBox.height * 0.5 - photo.scaledHeight * 0.5, 
					"scale.x": scale, 
					"scale.y": scale
				}, 0.8, {
					onUpdate: (_) -> photo.updateHitbox(),
					ease: FlxEase.backInOut
				});
			}
			else
			{
				photo.transitionTween = FlxTween.tween(photo, {
					y: carousel.centerY + item.y - photo.scaledHeight * 0.5 - FlxG.height
				}, 0.8, {
					ease: FlxEase.backIn, 
					startDelay: i / 100
				});
			}
		}

		FlxTween.cancelTweensOf(downloadBox);
		FlxTween.tween(downloadBox, {x: FlxG.width - downloadBox.width - 32}, 0.8, {ease: FlxEase.quartOut});
	}

	function deisolatePhoto():Void
	{
		if(!isolated) return;

		isolated = false;

		for(i in 0...carousel.length)
		{
			var item = carousel.positions[i];
			var photo = item.sprite;
			if(photo.transitionTween != null)
				photo.transitionTween.cancel();

			var scale = photo.calculateScale(item.size);
			
			photo.transitionTween = FlxTween.tween(photo, {
					x: carousel.centerX + item.x - photo.scaledWidth * 0.5, 
					y: carousel.centerY + item.y - photo.scaledHeight * 0.5, 
					"scale.x": scale,
					"scale.y": scale
				}, 0.8, {
					onUpdate: (_) -> photo.updateHitbox(),
					ease: FlxEase.backInOut, startDelay: i / 100
				});
		}

		FlxTween.cancelTweensOf(downloadBox);
		FlxTween.tween(downloadBox, {x: FlxG.width}, 0.8, {ease: FlxEase.quartOut});
	}

	override public function destroy():Void
	{
		super.destroy();

		generator.destroy();
		generator = null;

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
	}

	@:access(CatGenerator)
	@:noCompletion function get_progress():Float
	{
		return photoCache.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}