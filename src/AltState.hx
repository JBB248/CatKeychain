package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;

class AltState extends FlxTransitionableState
{
    public function new() 
    {
        super();
    }

    override public function create():Void
    {
        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.SPACE)
            FlxG.switchState(PlayState.new);
    }
}