package browse;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class CarouselPhoto extends FlxSprite
{
    /**
     * Simplified version of `setGraphicSize` that automatically
	 * calls `updateHitbox()` when set
     */
    public var size(default, set):Float = 0.0;

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

    @:noCompletion function set_size(value:Float):Float
    {
        var newScale = 1.0;
        if(frameWidth > frameHeight)
            newScale = value / frameWidth;
        else
            newScale = value / frameHeight;

        scale.set(newScale, newScale);
        updateHitbox();

        return size = value;
    }   
}