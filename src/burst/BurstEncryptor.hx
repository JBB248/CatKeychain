package burst;

import flixel.FlxG;
import openfl.display.BitmapData;

class BurstEncryptor
{
	public static inline var MASK:Int = 0x00000001;

    public static function encrypt(Pixels:BitmapData, Message:String):BitmapData
    {
        var index = Message.indexOf("~");
		if(index < 0)
		{
			Message += "~";
        }
		else if(index != Message.length - 1)
		{
			FlxG.log.warn('Cannot encrypt ${Message} because it contains "~"');
            return null;
        }

		var pixels = Pixels.clone();
		pixels.lock();

		var byte = 0;
		var x = 0;
		var y = 0;

		for(i in 0...Message.length)
		{
			byte = Message.charCodeAt(i);

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

		pixels.unlock();
		return pixels;
    }

    public static function decrypt(pixels:BitmapData):String
    {
		var message = new StringBuf();

		var byte = 0;
		var x = 0;
		var y = 0;

		while(byte != "~".code)
		{
			byte = 0;

			for(j in 0...8)
			{
				if(pixels.getPixel(x, y) & MASK == 1)
					byte |= 256; // Haxe strings are UTF-8 by default

				x++;
				if(x >= pixels.width)
				{
					x = 0;
					y++;
				}

				byte >>= 1;
			}

			message.addChar(byte);
		}

		return message.toString();
    }
}