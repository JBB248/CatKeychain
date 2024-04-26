package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;

import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;

class GalleryState extends FlxTransitionableState
{
    public var camTarget:FlxObject;

    public var gallery:FlxTypedContainer<GalleryPhoto>;

    public function new() 
    {
        super();
    }

    override public function create():Void
    {
        super.create();

        var savedGallery = AssetPaths.getGallery();

        if(savedGallery.length <  1)
        {
            var cat = new FlxSprite();
            cat.loadGraphic(AssetPaths.getEmbeddedImage("default-photo.png"));
            cat.screenCenter();

            add(cat);
        }
        else
        {
            gallery = new FlxTypedContainer();

            var matrix = [[]];
            var row = 0;
            var width = 0.0;
            for(graphic in savedGallery)
            {
                var photo = new GalleryPhoto(0, 0, graphic, this);
                if(photo.width + width > FlxG.width)
                {
                    matrix.push([]);
                    row++;
                    width = 0;
                }

                width += photo.width;
                matrix[matrix.length - 1].push(photo);
            }

            for(j => row in matrix)
            {
                var dx = (FlxG.width - Lambda.fold(row, (item, result) -> result + item.width, 0)) / 2;
                for(i => photo in row)
                {
                    var last = row[i - 1];
                    if(last != null)
                        photo.x = last.x + last.width;
                    else
                        photo.x = dx;

                    photo.y = FlxG.height / 3 * j;
                    photo.updateCenter();
                    add(photo);
                }
            }

            camTarget = new FlxObject(0, 0, FlxG.width, FlxG.height);

            FlxG.camera.setScrollBounds(0, FlxG.width, 0, GalleryPhoto.photoHeight * matrix.length);
            FlxG.worldBounds.set(0, 0, FlxG.width, GalleryPhoto.photoHeight * matrix.length);
            FlxG.camera.follow(camTarget, NO_DEAD_ZONE, 0.5);

            FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
            FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
        }
    }

    function onScroll(event:MouseEvent):Void
    {
        camTarget.y -= event.delta * 30;
        if(camTarget.y < FlxG.worldBounds.y)
            camTarget.y = 0;
        else if(camTarget.y + camTarget.height > FlxG.worldBounds.height)
            camTarget.y = FlxG.worldBounds.height - camTarget.height;
    }

    function onKeyReleased(event:KeyboardEvent):Void
    {
        switch(event.keyCode)
        {
            case FlxKey.F:
                if(event.controlKey)
                    findPhoto();
            case FlxKey.ESCAPE:
                FlxG.switchState(MainMenuState.new);
        }
    }

    function findPhoto():Void
    {

    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}


class GalleryPhoto extends FlxSprite
{
    public static inline var photoHeight:Float = 160;

    public var gallery:GalleryState;

    public var centerX:Float;
    public var centerY:Float;

    public function new(x:Float = 0, y:Float = 0, graphic:FlxGraphicAsset, gallery:GalleryState)
    {
        super(x, y, graphic);

        this.gallery = gallery;

        centerX = x + width * 0.5;
        centerY = y + height * 0.5;

        setGraphicSize(0, photoHeight);
        updateHitbox();

        FlxMouseEvent.add(this, onDown, onUp, onOver, onOut, false, true, false);
    }

    public function updateCenter():Void
    {
        centerX = x + width * 0.5;
        centerY = y + height * 0.5;
    }

    function onDown(_):Void
    {

    }

    function onUp(_):Void
    {

    }

    function onOver(_):Void
    {
        setGraphicSize(0, photoHeight * 1.5);
        updateHitbox();

        x = centerX - width * 0.5;
        y = centerY - height * 0.5;

        gallery.remove(this, true);
        gallery.add(this);
    }

    function onOut(_):Void
    {
        setGraphicSize(0, photoHeight);
        updateHitbox();

        x = centerX - width * 0.5;
        y = centerY - height * 0.5;
    }
}