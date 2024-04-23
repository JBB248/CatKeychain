package;

import burst.sys.BurstDotEnv;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.ui.FlxButtonPlus;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;

class MainMenuState extends FlxTransitionableState
{
    static var initialized:Bool = false;

    public var spinningCat:FlxSprite;
    public var catSize:Float = FlxG.width * 0.5 - 20;
    public var springSFX:FlxSound;

    public function new()
    {
        super();

        if(!initialized)
        {
            FlxG.autoPause = false;
                
            BurstDotEnv.init();
            Assets.init();

            FlxG.cameras.bgColor = 0xFFFFFFFF;

            var tileData:TransitionTileData = {
                asset: Assets.transitionTile,
                width: 32,
                height: 32
            };

            var transitionData = new TransitionData(TILES, 0xFFFFFFFF, 0.8, FlxPoint.get(1, 0), tileData);

            transOut =
            FlxTransitionableState.defaultTransIn = 
            FlxTransitionableState.defaultTransOut = transitionData;
        }
    }

    override public function create():Void
    {
        super.create();

        spinningCat = new FlxSprite();
        spinningCat.setFrames(FlxAtlasFrames.fromTexturePackerJson(FlxGraphic.fromClass(Assets.SpinningCatGraphic), new Assets.SpinningCatData().toString()));
        spinningCat.animation.addByPrefix("spin", "spin");
        spinningCat.animation.play("spin");
        spinningCat.setGraphicSize(catSize);
        spinningCat.updateHitbox();
        spinningCat.x = FlxG.width * 0.75 - spinningCat.width * 0.5;
        spinningCat.y = FlxG.height * 0.5 - spinningCat.height * 0.5;

        springSFX = new FlxSound().loadEmbedded(new Assets.SpringSound());
        
        var titleText = new FlxText(20, 20, FlxG.width * 0.5 - 40, "Cat Gallery", 60);
        titleText.color = 0xFF000000;

        var galleryButton = new FlxButtonPlus(20, titleText.height + 20, () -> FlxG.switchState(PlayState.new), "Gallery");
        galleryButton.updateInactiveButtonColors([0xFF414141, 0xFF000000]);
		galleryButton.updateActiveButtonColors([0xFFFF0000, 0xFF800000]);

        // add(new FlxBackdrop(Assets.backdropTile));
        add(spinningCat);
        add(titleText);
        add(galleryButton);
    }

    var catBounceElapsed:Float = 1.8;
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        catBounceElapsed += elapsed;

        if(FlxG.keys.justPressed.SPACE)
            FlxG.switchState(AltState.new);

        else if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(spinningCat))
        {
            springSFX.play(true);
            catBounceElapsed = 0.0;
        }

        if(catBounceElapsed < 1.8)
        {
            var wave = catSize * FlxEase.elasticOut(catBounceElapsed + 0.05);

            spinningCat.scale.x = Math.abs(wave / spinningCat.frameWidth);
            spinningCat.scale.y = Math.abs(wave / spinningCat.frameHeight);
            spinningCat.updateHitbox();
            spinningCat.x = FlxG.width * 0.75 - spinningCat.width * 0.5;
            spinningCat.y = FlxG.height * 0.5 - spinningCat.height * 0.5;
        }
    }
}