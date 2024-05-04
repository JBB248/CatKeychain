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

    /**
     * Used to ensure that only one tween from the carousel is 
	 * ever affecting this sprite
     */
    public var transitionTween:FlxTween;

	public var spinning:Bool = false;

	public var meta:Dynamic;

	override public function destroy():Void
	{
		super.destroy();
		
		transitionTween = null;
	}

    @:noCompletion function set_size(value:Float):Float
    {
        scale.set(value / frameWidth, value / frameHeight);
        updateHitbox();

        return size = value;
    }   
}