package;

import CatGenerator;
import PhotoCarousel;

import burst.BurstEncryptor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;

import sys.io.File;

class PlayState extends FlxState
{
	public static inline var TILE_SIZE:Int = 16;

	public var text:FlxTypeText;
	public var infoText:FlxText;
	public var button:FlxTypedButton<FlxSprite>;

	public var progressBar:FlxBar;
	public var progress(get, never):Float;

	public var carousel:PhotoCarousel;
	public var generator:CatGenerator;
	public var photoCount:Int = 16;

	public var isolated:Bool = false;

	var pixels:BitmapData;

	override public function create():Void
	{
		progressBar = new FlxBar(0, 0, null, TILE_SIZE * 16, TILE_SIZE, this, "progress", 0, 1);
		progressBar.createFilledBar(0xFFFFFFFF, 0xFF0F99EE);
		progressBar.filledCallback = () -> FlxTween.tween(progressBar, {alpha: 0}, 0.8);
		// progressBar.screenCenter();
		// progressBar.visible = false;

		var graphic = FlxG.bitmap.create(32, 32, 0xFFFFB6CC);
		graphic.bitmap.fillRect(new Rectangle(0, 0, TILE_SIZE, TILE_SIZE), 0xFFD4608E);
		graphic.bitmap.fillRect(new Rectangle(TILE_SIZE, TILE_SIZE, TILE_SIZE, TILE_SIZE), 0xFFD4608E);

		carousel = new PhotoCarousel(photoCount, FlxG.width * 0.5, FlxG.height * 0.5 - 120, 250, 80);

		generator = new CatGenerator();
		generator.onCatGenerated.add(catGenerated);
		generator.requestCat(photoCount);

		var textBackdrop = new FlxSprite(30, TILE_SIZE * 22).makeGraphic(FlxG.width - 60, TILE_SIZE * 8, 0xFFD4608E);
		text = new FlxTypeText(textBackdrop.x, textBackdrop.y, Std.int(textBackdrop.width), "Testing... Cat, neko, gato");
		infoText = new FlxText(0, 0, 0, "Select photo: UP | Deselect photo: DOWN | Spin carousel: LEFT, RIGHT, or mousewheel");
		infoText.alignment = CENTER;
		infoText.screenCenter(X);
		infoText.y = FlxG.height - infoText.height;

		add(new FlxBackdrop(graphic));
		add(carousel);
		add(textBackdrop);
		add(text);
		add(infoText);
		add(progressBar);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
		// To-do: Fix mouse wheel responsiveness
		// FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);

		/*********************** Encryption ***********************/

		pixels = BitmapData.fromFile("data/Ball.png");

		var encrypted = BurstEncryptor.encrypt(pixels, "Ball attack");
		File.saveBytes("data/Test.png", encrypted.encode(encrypted.rect, new PNGEncoderOptions()));

		encrypted = BitmapData.fromFile("data/Test.png");
		var message = BurstEncryptor.decrypt(encrypted);
	}

	function catGenerated(data:CatResponseData):Void
	{
		var sprite = new CarouselPhoto();
		sprite.antialiasing = true;
		sprite.meta = data;		
		sprite.loadGraphic(data.image);
		carousel.add(sprite);

		var item = carousel.positions[0];
		item.sprite = sprite;
		sprite.size = item.size;
		sprite.x = item.x - sprite.size * 0.5;
		sprite.y = item.y - sprite.size * 0.5;

		carousel.spin(COUNTER_CLOCKWISE);
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
		}
	}

	function keyReleased(event:KeyboardEvent):Void
	{
		switch(event.keyCode)
		{
			case FlxKey.LEFT | FlxKey.RIGHT:
				updateDescription();
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

		text.erase();
		text.skip();

		carousel.spin(direction);
	}

	function updateDescription():Void
	{
		if(carousel.length != photoCount) return;

		var photo = carousel.positions[0].sprite;
		var meta:CatResponseData = cast photo.meta;
		if(meta.breeds.length > 0)
			text.resetText(meta.breeds[0].description);
		else
			text.resetText("No description available :/");

		text.start(0.01, true, false, [SPACE]);
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

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
	}

	@:access(CatGenerator)
	@:noCompletion function get_progress():Float
	{
		return carousel.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}