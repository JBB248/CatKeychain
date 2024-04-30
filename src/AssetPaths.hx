package;

import CatGenerator;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;

import haxe.Json;

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

    public static function getGallery():Array<{graphic:FlxGraphic, data:CatResponseData}>
    {
        var dirs = FileSystem.readDirectory("gallery");

        return [for(id in dirs) {graphic: getGalleryPhoto(id), data: getGalleryData(id)}];
    }

    public static inline function getGalleryPhoto(id:String):FlxGraphic
    {
        return FlxG.bitmap.add(BitmapData.fromBytes(File.getBytes('gallery/${id}/photo.jpg')));
    }

    public static inline function getGalleryData(id:String):CatResponseData
    {
        return (cast Json.parse(File.getContent('gallery/${id}/data.json')));
    }
}