package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;

class AltState extends FlxTransitionableState
{
    public function new() 
    {
        super();
    }

    override public function create():Void
    {
        super.create();

        var cat = new FlxSprite();
        cat.loadGraphic(AssetPaths.getEmbeddedImage("default-photo.png"));
        cat.screenCenter();

        add(cat);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(MainMenuState.new);
    }
}