package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;

import sys.io.File;

class PlayState extends FlxState
{
	public static inline var MASK:Int = 1;

	public var text:FlxText;
	public var button:FlxButton;
	public var pixels:BitmapData;

	override public function create()
	{
		pixels = BitmapData.fromFile("data/Ball.png");

		text = new FlxText("Balls");
		button = new FlxButton(0, text.height, "Search");

		add(text);
		add(button);

		Sys.println("Encrypt: ");
		encrypt("Ball attack");
		Sys.println("\n\nDecrypt: ");
		Sys.println(decrypt());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function encrypt(message:String):Void
	{
		var index = message.indexOf("~");
		if(index < 0)
			message += "~";
		else if(index != message.length - 1)
			return FlxG.log.warn('Cannot encrypt ${message} because it contains "~"');

		var pixels = this.pixels.clone();
		pixels.lock();

		var byte = 0;
		var x = 0;
		var y = 0;

		for(i in 0...message.length)
		{
			byte = message.charCodeAt(i);

			for(j in 0...8)
			{
				if(byte & MASK == 1)
				{
					pixels.setPixel(x, y, pixels.getPixel(x, y) | 1);
				}
				else
				{
					pixels.setPixel(x, y, pixels.getPixel(x, y) & -2);
				}

				x++;
				if(x >= pixels.width)
				{
					x = 0;
					y++;
				}

				byte >>= 1;
			}
		}

		File.saveBytes("data/Test.png", pixels.encode(pixels.rect, new PNGEncoderOptions()));

		pixels.unlock();
		pixels.dispose();
	}

	function decrypt():String
	{
		var pixels = BitmapData.fromFile("data/Test.png");

		var message = new StringBuf();

		var byte = 0;
		var x = 0;
		var y = 0;

		while(byte != "~".code)
		{
			byte = 0;

			for(j in 0...8)
			{
				Sys.print(pixels.getPixel(x, y) & MASK);

				if(pixels.getPixel(x, y) & MASK == 1)
					byte |= 256; // Strings are UTF-8

				x++;
				if(x >= pixels.width)
				{
					x = 0;
					y++;
				}

				byte >>= 1;
			}

			Sys.println("\n" + byte);

			message.addChar(byte);
		}

		return message.toString();
	}
}
