package;

import CatGenerator;
import PhotoCarousel;
import burst.BurstEncryptor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.text.FlxTypeText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

import sys.io.File;

class PlayState extends FlxTransitionableState
{
	static var initialized:Bool = false;

	public static inline var TILE_SIZE:Int = 16;

	public var infoText:FlxTypeText;
	public var ctrlText:FlxText;
	public var mintTextFormat:FlxTextFormatMarkerPair = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF60D4A6), "@");

	public var progressBar:FlxBar;
	public var progress(get, never):Float;

	public var carousel:PhotoCarousel;
	public var generator:CatGenerator;
	public var photoCount:Int = 16;

	public var isolated:Bool = false;

	var pixels:BitmapData;

	public function new()
	{
		if(!initialized)
		{
			var diamond = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			var tileData:TransitionTileData = {
				asset: diamond,
				width: 32,
				height: 32
			};

			var transitionData = new TransitionData(TILES, FlxColor.WHITE, 1.2, FlxPoint.get(1, -1), tileData);

			FlxTransitionableState.defaultTransIn = transitionData;
			FlxTransitionableState.defaultTransOut = transitionData;

			initialized = true;
		}

		super();
	}

	override public function create():Void
	{
		super.create();

		progressBar = new FlxBar(0, 0, null, TILE_SIZE * 16, TILE_SIZE, this, "progress", 0, 1);
		progressBar.createFilledBar(0xFFFFFFFF, 0xFF60D4A6);
		progressBar.filledCallback = () -> FlxTween.tween(progressBar, {alpha: 0}, 0.8);
		// progressBar.screenCenter();
		// progressBar.visible = false;

		var graphic = FlxG.bitmap.create(32, 32, 0xFFFFB6CC);
		graphic.bitmap.fillRect(new Rectangle(0, 0, TILE_SIZE, TILE_SIZE), 0xFFD4608E);
		graphic.bitmap.fillRect(new Rectangle(TILE_SIZE, TILE_SIZE, TILE_SIZE, TILE_SIZE), 0xFFD4608E);

		carousel = new PhotoCarousel(photoCount, FlxG.width * 0.5, FlxG.height * 0.5 - 120, 250, 80);
		carousel.frontPhotoChanged.add((_) -> updateDescription());

		generator = new CatGenerator();
		generator.onCatGenerated.add(catGenerated);
		

		var textBackdrop = new FlxSprite(30, TILE_SIZE * 22).makeGraphic(FlxG.width - 60, TILE_SIZE * 8, 0xFFD4608E);
		infoText = new FlxTypeText(textBackdrop.x + 4, textBackdrop.y + 4, Std.int(textBackdrop.width) - 8, "Neko");
		ctrlText = new FlxText();
		ctrlText.applyMarkup("Skip text: @SPACE@ | Select photo: @UP@ | Deselect photo: @DOWN@ | Spin carousel: @LEFT@, @RIGHT@, or @Scroll wheel@", [mintTextFormat]);
		ctrlText.alignment = CENTER;
		ctrlText.screenCenter(X);
		ctrlText.y = FlxG.height - ctrlText.height;

		add(new FlxBackdrop(graphic));
		add(carousel);
		add(textBackdrop);
		add(infoText);
		add(ctrlText);
		add(progressBar);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
		FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);

		/*********************** Encryption ***********************/

		pixels = BitmapData.fromFile("data/Ball.png");

		var encrypted = BurstEncryptor.encrypt(pixels, "Ball attack");
		File.saveBytes("data/Test.png", encrypted.encode(encrypted.rect, new PNGEncoderOptions()));

		encrypted = BitmapData.fromFile("data/Test.png");
		var message = BurstEncryptor.decrypt(encrypted);
	}

	override public function finishTransIn():Void
	{
		super.finishTransIn();

		generator.requestCat(photoCount);
	}

	function catGenerated(data:CatResponseData):Void
	{
		var sprite = new CarouselPhoto();
		sprite.antialiasing = true;
		sprite.meta = data;		
		sprite.loadGraphic(data.image);
		carousel.positions[carousel.length].sprite = sprite;
		sprite.size = carousel.positions[carousel.length].size;
		sprite.x = -sprite.width;
		sprite.y = -sprite.height;

		carousel.add(sprite);

		if(carousel.length == photoCount)
		{
			carousel.members.sort((O1, O2) -> Std.int(O1.size - O2.size));

			for(i in 0...photoCount)
			{
				var point = carousel.positions[i];

				FlxTween.tween(point.sprite, {
					x: carousel.centerX + point.x - point.size * 0.5, 
					y: carousel.centerY + point.y - point.size * 0.5,
					size: point.size
				}, 0.3, {startDelay: i / 20, ease: FlxEase.backOut});
			}

			updateDescription();
		}
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

			case FlxKey.ENTER | FlxKey.UP:
				isolatePhoto();
			case FlxKey.DOWN:
				deisolatePhoto();

			case FlxKey.SPACE:
				FlxG.switchState(AltState.new);
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
		var meta:CatResponseData = cast photo.meta;
		if(meta.breeds.length > 0)
		{
			var cat = meta.breeds[0].name;
			var origin = meta.breeds[0].origin;
			var temperament = meta.breeds[0].temperament;
			var description = meta.breeds[0].description;

			var displayText = '@Cat name:@ ${cat}\n\n' 
				+ '@Origin:@ ${origin}\n\n'
				+ '@Temperament:@ ${temperament}\n\n'
				+ '@Description:@ ${description}';

			infoText.applyMarkup(displayText, [mintTextFormat]);
		}
		else
		{
			infoText.resetText("No description available :/");
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
			if(item.sprite.transitionTween != null)
				item.sprite.transitionTween.cancel();

			item.sprite.transitionTween = 
			if(i == 0)
				FlxTween.tween(item.sprite, 
					{x: FlxG.width * 0.5 - TILE_SIZE * 9, y: 32, size: TILE_SIZE * 18}, 0.8, 
					{ease: FlxEase.backInOut});
			else
				FlxTween.tween(item.sprite, 
					{y: carousel.centerY + item.y - item.size * 0.5 - FlxG.height}, 0.8, 
					{ease: FlxEase.backIn, startDelay: i / 100});
		}
	}

	function deisolatePhoto():Void
	{
		if(!isolated) return;

		isolated = false;

		for(i in 0...carousel.length)
		{
			var item = carousel.positions[i];
			if(item.sprite.transitionTween != null)
				item.sprite.transitionTween.cancel();

			item.sprite.transitionTween = FlxTween.tween(item.sprite, {
					x: carousel.centerX + item.x - item.size * 0.5, 
					y: carousel.centerY + item.y - item.size * 0.5, 
					size: item.size
				}, 0.8, {ease: FlxEase.backInOut, startDelay: i / 100});
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		generator.destroy();

		generator = null;
		mintTextFormat = null;

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
	}

	@:access(CatGenerator)
	@:noCompletion function get_progress():Float
	{
		return carousel.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}