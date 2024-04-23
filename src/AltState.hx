package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;

import openfl.display.BitmapData;

@:bitmap("build-assets/default-photo.png") class DefaultPhotoGraphic extends BitmapData { }

class AltState extends FlxTransitionableState
{
    public function new() 
    {
        super();
    }

    override public function create():Void
    {
        bgColor = 0xFF000000;

        super.create();

        var cat = new FlxSprite();
        cat.loadGraphic(FlxGraphic.fromClass(DefaultPhotoGraphic));
        cat.screenCenter();

        add(cat);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.SPACE)
            FlxG.switchState(PlayState.new);
    }
}