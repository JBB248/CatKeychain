package browse;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class CarouselPhoto extends FlxSprite
{
    public var scaledWidth:Float = 1.0;
    public var scaledHeight:Float = 1.0;

    /**
     * Used to ensure that only one tween from the carousel is 
	 * ever affecting this sprite
     */
    public var transitionTween:FlxTween;

	public var spinning:Bool = false;

	public var meta:Dynamic;

    public inline function calculateScale(size:Float):Float
    {
        return frameWidth > frameHeight ? size / frameWidth : size / frameHeight;
    }

	override public function destroy():Void
	{
		super.destroy();
		
		transitionTween = null;
	}
}