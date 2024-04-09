package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class CarouselSprite extends FlxSprite
{
    public var size(default, set):Float = 0.0;

    public var transitionTween:FlxTween;

    @:noCompletion function set_size(value:Float):Float
    {
        scale.set(value / frameWidth, value / frameHeight);
        updateHitbox();

        return size = value;
    }   
}