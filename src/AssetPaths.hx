package;

import CatGenerator;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;

import haxe.Json;

import openfl.Assets;
import openfl.display.BitmapData;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

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
        #if sys
        if(!FileSystem.exists("gallery")) return [];

        var dirs = FileSystem.readDirectory("gallery");
        return [for(id in dirs) {graphic: getGalleryPhoto(id), data: getGalleryData(id)}];
        #else
        return [];
        #end
    }

    public static function getGalleryPhoto(id:String):FlxGraphic
    {
        var path = 'gallery/${id}/photo.png';
        return if 
            #if sys (FileSystem.exists(path)) FlxG.bitmap.add(BitmapData.fromFile(path)) 
            #else (Assets.exists(path, IMAGE)) FlxG.bitmap.add(path);
            #end else getEmbeddedImage("default-photo.png");
    }

    public static function getGalleryData(id:String):CatData
    {
        var path = 'gallery/${id}/data.json';
        var data = if
            #if sys (FileSystem.exists(path)) File.getContent(path)
            #else (Assets.exists(path)) Assets.getText(path)
            #end else CatGenerator.emptyData;

        return (cast Json.parse(data));
    }
}