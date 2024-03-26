package;

import burst.util.BurstImageUtil;
import burst.BurstEncryptor;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;

import sys.io.File;

class PlayState extends FlxState
{
	public var text:FlxText;
	public var button:FlxButton;
	public var pixels:BitmapData;

	override public function create():Void
	{
		pixels = BitmapData.fromFile("data/Ball.png");

		text = new FlxText("Balls");
		button = new FlxButton(0, text.height, "Search");

		add(text);
		add(button);

		var encrypted = BurstEncryptor.encrypt(pixels, "Ball attack");
		File.saveBytes("data/Test.png", encrypted.encode(encrypted.rect, new PNGEncoderOptions()));

		Sys.print("\nDecrypt: ");
		encrypted = BitmapData.fromFile("data/Test.png");
		Sys.println(BurstEncryptor.decrypt(encrypted));

		BurstImageUtil.getFromGoogleSearch();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
