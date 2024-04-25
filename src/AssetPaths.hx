package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;

import openfl.Assets;
import openfl.display.BitmapData;

import sys.FileSystem;
import sys.io.File;

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

    public static function getGallery():Array<FlxGraphic>
    {
        var dir = FileSystem.readDirectory("gallery");

        return [for(file in dir) getGalleryImage(file)];
    }

    public static function getGalleryImage(id:String):FlxGraphic
    {
        return FlxG.bitmap.add(BitmapData.fromBytes(File.getBytes('gallery/${id}')));
    }
}