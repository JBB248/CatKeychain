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
    public static function getData(path:String, library:String = "data", embedded:Bool = false):String
    {
        return Assets.getText(getPath(path, library, embedded));
    }

    public static function getImage(path:String, library:String = "images", embedded:Bool = false):FlxGraphic
    {
        return FlxG.bitmap.add(getPath(path, library, embedded));
    }

    public static function getSound(path:String, library:String = "sounds", embedded:Bool = false):FlxSound
    {
        return new FlxSound().loadEmbedded(getPath(path, library, embedded));
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

    static function getGalleryPhoto(id:String):FlxGraphic
    {
        var path = 'gallery/${id}/photo.png';
        return if 
            #if sys (FileSystem.exists(path)) FlxG.bitmap.add(BitmapData.fromFile(path)) 
            #else (Assets.exists(path, IMAGE)) FlxG.bitmap.add(path);
            #end else getImage("default-photo.png", true);
    }

    static function getGalleryData(id:String):CatData
    {
        var path = 'gallery/${id}/data.json';
        var data = if
            #if sys (FileSystem.exists(path)) File.getContent(path)
            #else (Assets.exists(path)) Assets.getText(path)
            #end else CatGenerator.emptyData;

        return (cast Json.parse(data));
    }
}