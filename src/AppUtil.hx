package;

import flixel.text.FlxText;
import flixel.util.FlxColor;

class AppUtil
{
    public static var SOFT_BLACK:FlxColor = 0xFF212529;
    public static var SOFT_WHITE:FlxColor = 0xFFE9ECEF;
    public static var NAVY:FlxColor = 0xFF101C2F;
    public static var SOFT_NAVY:FlxColor = 0xFF252F40;

    public static var ICE:FlxColor = 0xFF17C1E8;

	public static function getIceTextFormat():FlxTextFormatMarkerPair
	{
        return new FlxTextFormatMarkerPair(new FlxTextFormat(ICE), "@");
    }
}