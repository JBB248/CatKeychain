package browse;

import CatGenerator.CatData;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

import lime.tools.Orientation;

/**
 * Photo used in Carousel with shortcuts to recalculate size base on depth.
 * Check `meta` for data on the photo from theCatAPI.
 */
class CarouselPhoto extends FlxSprite
{
    public var orientation:Orientation = LANDSCAPE;

    public var scaledWidth:Float = 1.0;
    public var scaledHeight:Float = 1.0;

    /**
     * Used to ensure that only one tween from the carousel is 
	 * ever affecting this sprite
     */
    public var transitionTween:FlxTween;

	public var spinning:Bool = false;

	public var meta:CatData;

    override public function graphicLoaded():Void
    {
        orientation = frameWidth > frameHeight ? LANDSCAPE : PORTRAIT;
    }

    public function calculateScale(size:Float):Float
    {
        var scale = orientation == LANDSCAPE ? size / frameWidth : size / frameHeight;
        scaledWidth = frameWidth * scale;
		scaledHeight = frameHeight * scale;
        return scale;
    }

	override public function destroy():Void
	{
		super.destroy();
		
		transitionTween = null;
	}
}