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

    public static function getPath(path:String, library:String, embedded:Bool = false):String
    {
        return '${embedded ? "embedded" : "assets"}/${library}/${path}';
    }

    public static function getGallery():Array<{graphic:FlxGraphic, data:CatData}>
    {
        if(!FileSystem.exists("gallery")) return [];

        var dirs = FileSystem.readDirectory("gallery");
        return [for(id in dirs) {graphic: getGalleryPhoto(id), data: getGalleryData(id)}];
    }

    public static function getGalleryPhoto(id:String):FlxGraphic
    {
        var path = 'gallery/${id}/photo.png';
        if(FileSystem.exists(path))
            return FlxG.bitmap.add(BitmapData.fromFile('gallery/${id}/photo.png'));
        else
            return getEmbeddedImage("default-photo.png");
    }

    public static function getGalleryData(id:String):CatData
    {
        var path = 'gallery/${id}/data.json';
        if(FileSystem.exists(path))
            return (cast Json.parse(File.getContent(path)));
        else
            return CatGenerator.emptyData;
    }
}