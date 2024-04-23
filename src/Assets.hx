package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.graphics.FlxGraphic;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

@:bitmap("build-assets/default-photo.png") class DefaultPhotoGraphic extends BitmapData { }

@:bitmap("build-assets/spin-cat.png") class SpinningCatGraphic extends BitmapData { }
@:file("build-assets/spin-cat.json") class SpinningCatData extends ByteArrayData { }

class Assets
{
    public static inline var TILE_SIZE:Int = 16;
    
    public static var backdropTile:FlxGraphic;
    public static var transitionTile:FlxGraphic;

    @:allow(MainMenuState)
    static function init():Void
    {
        backdropTile = FlxG.bitmap.create(32, 32, 0xFFFFB6CC);
		backdropTile.bitmap.fillRect(new Rectangle(0, 0, TILE_SIZE, TILE_SIZE), 0xFFD4608E);
		backdropTile.bitmap.fillRect(new Rectangle(TILE_SIZE, TILE_SIZE, TILE_SIZE, TILE_SIZE), 0xFFD4608E);
        backdropTile.destroyOnNoUse = false;
        backdropTile.persist = true;

        transitionTile = FlxGraphic.fromClass(GraphicTransTileSquare);
        transitionTile.persist = true;
        transitionTile.destroyOnNoUse = false;
    }
}