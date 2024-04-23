package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import burst.sys.BurstDotEnv;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;

class MainMenuState extends FlxTransitionableState
{
    public function new()
    {
        super();
    }

    override public function create():Void
    {
        FlxG.autoPause = false;
        
        BurstDotEnv.init();
        Assets.init();

        super.create();

        var tileData:TransitionTileData = {
            asset: Assets.transitionTile,
            width: 32,
            height: 32
        };

        var transitionData = new TransitionData(TILES, 0xFFFFFFFF, 0.8, FlxPoint.get(1, 0), tileData);
        transOut = transitionData;

        FlxTransitionableState.defaultTransIn = transitionData;
        FlxTransitionableState.defaultTransOut = transitionData;

        /*********************** Actual Menu UI ***********************/

        var spinningCat = new FlxSprite();
        spinningCat.setFrames(FlxAtlasFrames.fromTexturePackerJson(FlxGraphic.fromClass(Assets.SpinningCatGraphic), new Assets.SpinningCatData().toString()));
        spinningCat.animation.addByPrefix("spin", "spin");
        spinningCat.animation.play("spin");
        spinningCat.setGraphicSize(FlxG.width * 0.5 - 20);
        spinningCat.updateHitbox();
        spinningCat.x = FlxG.width * 0.75 - spinningCat.width * 0.5;
        spinningCat.y = FlxG.height * 0.5 - spinningCat.height * 0.5;

        add(new FlxBackdrop(Assets.backdropTile));
        add(new FlxSprite(FlxG.width * 0.5).makeGraphic(Std.int(FlxG.width * 0.5), FlxG.height));
        add(spinningCat);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.SPACE)
            FlxG.switchState(AltState.new);
    }
}