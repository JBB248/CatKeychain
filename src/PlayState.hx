package;

import CatGenerator;
import burst.BurstEncryptor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;

import sys.io.File;

class PlayState extends FlxState
{
	public var text:FlxText;
	public var button:FlxTypedButton<FlxSprite>;

	public var progressBar:FlxBar;
	public var progress(get, never):Float;

	public var carousel:PhotoCarousel;
	public var generator:CatGenerator;
	public var photoCount:Int = 15;

	var pixels:BitmapData;

	override public function create():Void
	{
		progressBar = new FlxBar(0, 0, null, 16 * 15, 15, this, "progress", 0, 1);
		progressBar.createFilledBar(0xFFFF3535, 0xFF0F99EE);
		// progressBar.screenCenter();
		// progressBar.visible = false;

		var graphic = FlxG.bitmap.create(30, 30, 0xFFFFB6CC);
		graphic.bitmap.fillRect(new Rectangle(0, 0, 15, 15), 0xFFD4608E);
		graphic.bitmap.fillRect(new Rectangle(15, 15, 15, 15), 0xFFD4608E);

		carousel = new PhotoCarousel(photoCount);

		generator = new CatGenerator();
		generator.onCatGenerated.add(catGenerated);
		generator.requestCat(photoCount);

		text = new FlxText(40, FlxG.height * 0.5 + 100);

		add(new FlxBackdrop(graphic));
		add(carousel);
		add(text);
		add(progressBar);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);

		/*********************** Encryption ***********************/

		pixels = BitmapData.fromFile("data/Ball.png");

		var encrypted = BurstEncryptor.encrypt(pixels, "Ball attack");
		File.saveBytes("data/Test.png", encrypted.encode(encrypted.rect, new PNGEncoderOptions()));

		encrypted = BitmapData.fromFile("data/Test.png");
		var message = BurstEncryptor.decrypt(encrypted);
	}

	function catGenerated(data:CatResponseData):Void
	{
		var sprite = new CarouselSprite();
		sprite.antialiasing = true;
		sprite.loadGraphic(data.image);
		carousel.add(sprite);

		// text.text = Std.string(data.breeds);

		var item = carousel.positions[0];
		item.sprite = sprite;
		sprite.size = item.size;
		sprite.x = item.x - sprite.size * 0.5;
		sprite.y = item.y - sprite.size * 0.5;

		carousel.spin(true);
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
				carousel.spin(true);
			case FlxKey.RIGHT:
				carousel.spin(false);

			case FlxKey.DOWN:
				isolatePhoto();
			case FlxKey.UP:
				deisolatePhoto();
		}
	}

	function isolatePhoto():Void
	{
		var item = carousel.positions[0];
		var sprite = carousel.positions[0].sprite;

		FlxTween.tween(sprite, {x: FlxG.width * 0.5 - (item.size + 100) * 0.5, y: 40, size: item.size + 100}, 0.8, {ease: FlxEase.sineIn});

		for(i in 1...carousel.length)
		{
			var item = carousel.positions[i];
			FlxTween.tween(item.sprite, {y: item.y - item.size * 0.5 - FlxG.height}, 0.8, {ease: FlxEase.backIn, startDelay: i / 100});
		}
	}

	function deisolatePhoto():Void
	{
		for(i in 0...carousel.length)
		{
			var item = carousel.positions[i];
			FlxTween.tween(item.sprite, {x: item.x - item.size * 0.5, y: item.y - item.size * 0.5, size: item.size}, 0.8, {ease: FlxEase.backOut, startDelay: i / 100});
		}
	}

	@:noCompletion function get_progress():Float
	{
		return carousel.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}