package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class CarouselSprite extends FlxSprite
{
    /**
     * Not actually a "z" value. Setting this just resizes the sprite.
     * Would not recommend use outside this setting.
     */
    public var z(default, set):Float = 0.0;

    public var transitionTween:FlxTween;

    @:noCompletion function set_z(value:Float):Float
    {
        scale.set(value / frameWidth, value / frameHeight);
        updateHitbox();

        return z = value;
    }   
}