package;

import burst.BurstEncryptor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;

import sys.io.File;

class PlayState extends FlxState
{
	public var text:FlxText;
	public var button:FlxButton;

	public var progressBar:FlxBar;
	public var progress(get, never):Float;

	public var photos:FlxGroup;
	public var photoCount:Int = 15;

	public var generator:CatGenerator;

	var pixels:BitmapData;

	override public function create():Void
	{
		photos = new FlxGroup(photoCount);

		text = new FlxText("Balls");
		button = new FlxButton(0, text.height, "Search");

		progressBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.4), 10, this, "progress", 0, 1);
		progressBar.createFilledBar(0xFFFF0000, 0xFF111199);
		progressBar.setPosition(FlxG.width - progressBar.width - 5, FlxG.height - progressBar.height - 5);

		generator = new CatGenerator();
		generator.onCatGenerated.add(catGenerated);
		generator.requestCat(photoCount);

		add(photos);
		add(text);
		add(button);
		add(progressBar);

		/*********************** Encryption ***********************/

		pixels = BitmapData.fromFile("data/Ball.png");

		var encrypted = BurstEncryptor.encrypt(pixels, "Ball attack");
		File.saveBytes("data/Test.png", encrypted.encode(encrypted.rect, new PNGEncoderOptions()));

		encrypted = BitmapData.fromFile("data/Test.png");
		var message = BurstEncryptor.decrypt(encrypted);
	}

	function catGenerated(pixels:BitmapData):Void
	{
		var sprite = new FlxSprite().loadGraphic(pixels);
		sprite.antialiasing = true;
		if(sprite.width > sprite.height)
			sprite.setGraphicSize(FlxG.width);
		else
			sprite.setGraphicSize(0, FlxG.height);
		sprite.updateHitbox();
		// sprite.screenCenter();
		photos.add(sprite);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	@:noCompletion function get_progress():Float
	{
		return photos.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}
