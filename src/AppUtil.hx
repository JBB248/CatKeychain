package;

import flixel.text.FlxText;
import flixel.util.FlxColor;

class AppUtil
{
    public static var SOFT_BLACK:FlxColor = 0xFF212529;
    public static var SOFT_WHITE:FlxColor = 0xFFD0D6E0;
    public static var NAVY:FlxColor = 0xFF101C2F;
    public static var SOFT_NAVY:FlxColor = 0xFF252F40;
    public static var ICE:FlxColor = 0xFF17C1E8;

    public static var mouseWheel:MouseWheel;

	public static function getIceTextFormat():FlxTextFormatMarkerPair
	{
        return new FlxTextFormatMarkerPair(new FlxTextFormat(ICE), "@");
    }

    public static function compareTo(a:String, b:String):Int
    {
        if(a == b)
            return 0;

        var min = Std.int(Math.min(a.length, b.length));
        for(i in 0...min)
        {
            var ac = a.charCodeAt(i);
            var bc = b.charCodeAt(i);
            if(ac != bc)
                return ac - bc;
        }

        return a.length - b.length;
    }
}