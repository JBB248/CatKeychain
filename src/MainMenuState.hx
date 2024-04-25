package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.ui.FlxButton;

import openfl.geom.Rectangle;

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
            FlxG.cameras.bgColor = 0xFFFFFFFF;

            var transitionTile = FlxGraphic.fromClass(GraphicTransTileSquare);
            transitionTile.persist = true;
            transitionTile.destroyOnNoUse = false;

            var tileData:TransitionTileData = {
                asset: transitionTile,
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
        spinningCat.setFrames(FlxAtlasFrames.fromTexturePackerJson(AssetPaths.getEmbeddedImage("spin-cat.png"), AssetPaths.getEmbeddedData("spin-cat.json", "images")));
        spinningCat.animation.addByPrefix("spin", "spin");
        spinningCat.animation.play("spin");
        spinningCat.setGraphicSize(catSize);
        spinningCat.updateHitbox();
        spinningCat.x = FlxG.width * 0.75 - spinningCat.width * 0.5;
        spinningCat.y = FlxG.height * 0.5 - spinningCat.height * 0.5;

        springSFX = AssetPaths.getEmbeddedSound("boing.ogg");
        
        var titleText = new FlxText(20, 40, FlxG.width * 0.5 - 40, "Cat Gallery", 60);
        titleText.color = 0xFF000000;

        var galleryButton = new MenuButton(22, titleText.y +  titleText.height + 15, "Visit Gallery");
        galleryButton.onUp.callback = () -> FlxG.switchState(GalleryState.new);

        var browseButton = new MenuButton(galleryButton.x + galleryButton.width + 10, galleryButton.y, "Browse CatAPI");
        browseButton.onUp.callback = () -> FlxG.switchState(BrowseState.new);

        var creditsButton = new MenuButton(browseButton.x + browseButton.width + 10, galleryButton.y, "View Credits");
        creditsButton.onUp.callback = () -> {/* Play SFX */};

        add(spinningCat);
        add(titleText);
        add(galleryButton);
        add(browseButton);
        add(creditsButton);
    }

    var catBounceElapsed:Float = 1.8;
    var deltaX:Float = 0;
    var ratioY:Float = 1;

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(spinningCat))
        {
            springSFX.play(true);
            catBounceElapsed = 0.0;
            deltaX = FlxG.random.float(-0.2, 0.2);
            ratioY = FlxG.random.floatNormal(spinningCat.frameHeight / spinningCat.frameWidth, 0.2);
        }
        if(catBounceElapsed < 1.8)
        {
            catBounceElapsed += elapsed;

            var wave = catSize * FlxEase.elasticOut(catBounceElapsed + 0.05);

            spinningCat.scale.x = Math.abs((wave + deltaX) / spinningCat.frameWidth);
            spinningCat.scale.y = Math.abs(wave * ratioY / spinningCat.frameHeight);
            spinningCat.updateHitbox();
            spinningCat.x = FlxG.width * 0.75 - spinningCat.width * 0.5;
            spinningCat.y = FlxG.height * 0.5 - spinningCat.height * 0.5;
        }
    }
}

class MenuButton extends FlxButton
{
    public function new(x:Float, y:Float, text:String)
    {
        super(x, y, text);

        var newGraphic = FlxG.bitmap.create(80, 80, 0xFFFFFFFF, true);

        newGraphic.bitmap.fillRect(new Rectangle(0, 20, 80, 20), 0xFF000000);
        newGraphic.bitmap.fillRect(new Rectangle(2, 22, 76, 16), 0xFFFFFFFF);
        newGraphic.bitmap.fillRect(new Rectangle(0, 40, 80, 40), 0xFF000000);

        loadGraphic(newGraphic, true, 80, 20);
        label.color = 0xFF000000;

        allowSwiping = false;
    }

    override public function onDownHandler():Void
    {
        label.color = 0xFFFFFFFF;
        
        super.onDownHandler();
    }

    override public function onUpHandler():Void
    {
        label.color = 0xFF000000;

        super.onUpHandler();
    }

    override public function onOutHandler():Void
    {
        if(status == PRESSED)
            label.color = 0xFF000000;

        super.onOutHandler();
    }
}