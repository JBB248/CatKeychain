package;

import AppUtil.SOFT_BLACK;
import AppUtil.SOFT_WHITE;

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
import flixel.util.FlxColor;

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
            #if BURST_BUILD
            burst.Burst.init();
            #end

            FlxG.autoPause = false;

            FlxG.sound.volumeDownKeys = null; // Prevent these from dinging while the user is typing
            FlxG.sound.volumeUpKeys = null;
            FlxG.sound.muteKeys = null;

            AppUtil.mouseWheel = new MouseWheel();
            
            var transitionTile = FlxGraphic.fromClass(GraphicTransTileSquare);
            transitionTile.persist = true;
            transitionTile.destroyOnNoUse = false;

            var tileData:TransitionTileData = {
                asset: transitionTile,
                width: 32,
                height: 32
            };

            var transitionData = new TransitionData(TILES, SOFT_WHITE, 0.8, FlxPoint.get(1, 0), tileData);

            transOut =
            FlxTransitionableState.defaultTransIn = 
            FlxTransitionableState.defaultTransOut = transitionData;
        }
    }

    override public function create():Void
    {
        super.create();

        FlxG.camera.bgColor = FlxColor.WHITE;

        spinningCat = new FlxSprite();
        spinningCat.setFrames(FlxAtlasFrames.fromTexturePackerJson(AssetPaths.getImage("spin-cat.png", true), AssetPaths.getData("spin-cat.json", "images", true)));
        spinningCat.animation.addByPrefix("spin", "spin");
        spinningCat.animation.play("spin");
        spinningCat.setGraphicSize(catSize);
        spinningCat.updateHitbox();
        spinningCat.x = FlxG.width * 0.75 - spinningCat.width * 0.5;
        spinningCat.y = FlxG.height * 0.5 - spinningCat.height * 0.5;

        springSFX = AssetPaths.getSound("boing.ogg", true);
        
        var title = new FlxText(20, 40, FlxG.width * 0.5 - 40, "Cat Gallery", 60);
        title.color = SOFT_BLACK;

        var subTitle = new FlxText("By Joe Bray", 16);
        subTitle.x = 5;
        subTitle.y = FlxG.height - subTitle.height - 5;
        subTitle.color = SOFT_BLACK;

        var buttonColors = [SOFT_WHITE, SOFT_BLACK, FlxColor.WHITE];

        var galleryButton = new MenuButton(22, title.y +  title.height + 15, "Visit Gallery", buttonColors);
        galleryButton.onUp.callback = () -> FlxG.switchState(gallery.GalleryState.new);
        var galleryText = new FlxText(galleryButton.x, galleryButton.y + galleryButton.height + 24, 0, "View your gallery of saved cat photos");
        galleryText.color = AppUtil.SOFT_BLACK;
        galleryText.kill();
        galleryButton.onOver.callback = () -> galleryText.revive();
        galleryButton.onOut.callback = () -> galleryText.kill();

        var browseButton = new MenuButton(galleryButton.x + galleryButton.width + 10, galleryButton.y, "Browse CatAPI", buttonColors);
        browseButton.onUp.callback = () -> FlxG.switchState(browse.BrowseState.new);
        var browseText = new FlxText(galleryText.x, galleryText.y, 0, "Download photos from TheCatAPI to view in your gallery later");
        browseText.color = AppUtil.SOFT_BLACK;
        browseText.kill();
        browseButton.onOver.callback = () -> browseText.revive();
        browseButton.onOut.callback = () -> browseText.kill();

        var creditsButton = new MenuButton(browseButton.x + browseButton.width + 10, galleryButton.y, "View Credits", buttonColors);
        creditsButton.onUp.callback = () -> catSpring();
        var creditsText = new FlxText(galleryText.x, galleryText.y, 0, 
            "- Cat photos sourced from TheCatAPI.com\n\n- Spinning maxwell cat sourced from r/Catloaf\n\n- Powered by HaxeFlixel");
        creditsText.color = AppUtil.SOFT_BLACK;
        creditsText.kill();
        creditsButton.onOver.callback = () -> creditsText.revive();
        creditsButton.onOut.callback = () -> creditsText.kill();

        add(spinningCat);
        add(title);
        add(subTitle);
        add(galleryButton);
        add(browseButton);
        add(creditsButton);
        add(galleryText);
        add(browseText);
        add(creditsText);
    }

    // helper vars to manage spinning cat
    var catBounceElapsed:Float = 1.8;
    var deltaX:Float = 0;
    var ratioY:Float = 1;

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(spinningCat))
        {
            catSpring();
        }
        if(catBounceElapsed < 1.8) // Simulate FlxTween so that hitbox can be updated each frame
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

    /**
     * Make the cat go BOING!!
     */
    function catSpring():Void
    {
        springSFX.play(true);
        catBounceElapsed = 0.0;
        deltaX = FlxG.random.float(-0.2, 0.2);
        ratioY = FlxG.random.floatNormal(spinningCat.frameHeight / spinningCat.frameWidth, 0.2);
    }
}

class MenuButton extends FlxButton
{
    public var colors:Array<FlxColor>;

    public function new(x:Float, y:Float, text:String, colors:Array<FlxColor>)
    {
        super(x, y, text);

        this.colors = colors.copy();

        var newGraphic = FlxG.bitmap.create(80, 80, colors[0], true);

        newGraphic.bitmap.fillRect(new Rectangle(0, 20, 80, 20), colors[1]);
        newGraphic.bitmap.fillRect(new Rectangle(2, 22, 76, 16), colors[2]);
        newGraphic.bitmap.fillRect(new Rectangle(0, 40, 80, 40), colors[1]);

        loadGraphic(newGraphic, true, 80, 20);
        label.color = colors[1];

        allowSwiping = false;
    }

    override public function onDownHandler():Void
    {
        label.color = colors[0];
        
        super.onDownHandler();
    }

    override public function onUpHandler():Void
    {
        label.color = colors[1];

        super.onUpHandler();
    }

    override public function onOutHandler():Void
    {
        if(status == PRESSED)
            label.color = colors[1];

        super.onOutHandler();
    }
}