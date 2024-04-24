package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;

import openfl.Assets;

class AssetPaths
{
    public static function getEmbeddedData(path:String, library:String = "data"):String
    {
        return Assets.getText(getPath(path, library, true));
    }

    public static function getEmbeddedImage(path:String, library:String = "images"):FlxGraphic
    {
        return FlxG.bitmap.add(getPath(path, library, true));
    }

    public static function getEmbeddedSound(path:String, library:String = "sounds"):FlxSound
    {
        return new FlxSound().loadEmbedded(getPath(path, library, true));
    }

    static function getPath(path:String, library:String, embedded:Bool = false):String
    {
        return '${embedded ? "embedded" : "assets"}/${library}/${path}';
    }
}