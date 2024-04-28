package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil;

class GalleryState extends FlxTransitionableState
{
    public var camTarget:FlxObject;

    public var gallery:FlxTypedGroup<GalleryPhoto>;
    public var focus(default, set):GalleryPhoto;

    public var viewSubState:GallerySubState;

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
            camTarget = new FlxObject(0, 0, FlxG.width, FlxG.height);
            viewSubState = new GallerySubState();
            destroySubStates = false;

            gallery = new FlxTypedGroup(); // FlxContainer has a child/parent relationship that bothers the substate
            add(gallery);

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

            for(j => row in matrix) // Find a way to remove this
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
                    gallery.add(photo);
                }
            }

            FlxG.worldBounds.set(0, 0, FlxG.width, GalleryPhoto.photoHeight * matrix.length);
            FlxG.camera.setScrollBounds(0, FlxG.width, 0, GalleryPhoto.photoHeight * matrix.length);
            FlxG.camera.follow(camTarget, NO_DEAD_ZONE, 0.5);
        }
    }

    public function isolatePhoto(photo:GalleryPhoto):Void
    {
        openSubState(viewSubState.reset(photo));
    }

    function findPhoto():Void
    {

    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        final keys = FlxG.keys;
        if(keys.justReleased.F && keys.pressed.CONTROL)
        {
            findPhoto();
        }
        else if(keys.justReleased.ESCAPE)
        {
            FlxG.switchState(MainMenuState.new);
        }

        // Update scroll
        camTarget.y -= FlxG.mouse.wheel * 40;
        if(camTarget.y < FlxG.worldBounds.y)
            camTarget.y = 0;
        else if(camTarget.y + camTarget.height > FlxG.worldBounds.height)
            camTarget.y = FlxG.worldBounds.height - camTarget.height;
    }

    override public function closeSubState():Void
    {
        super.closeSubState();

        focus = null; // Make sure the photo resets, even if it's still being targeted
    }

    override public function destroy():Void
    {
        super.destroy();

        viewSubState = FlxDestroyUtil.destroy(viewSubState);
    }

    @:noCompletion function set_focus(value:GalleryPhoto):GalleryPhoto
    {
        if(focus != null)
        {
            // Restore old focus to original size
            focus.setGraphicSize(0, GalleryPhoto.photoHeight);
            focus.updateHitbox();

            focus.x = focus.centerX - focus.width * 0.5;
            focus.y = focus.centerY - focus.height * 0.5;
        }

        if(value != null)
        {
            // Enlarge new focus to make it stand out
            value.setGraphicSize(0, GalleryPhoto.photoHeight * 1.25);
            value.updateHitbox();

            value.x = value.centerX - value.width * 0.5;
            value.y = value.centerY - value.height * 0.5;

            // Move new focus to top of draw stack
            final members = gallery.members;
            members.push(members.splice(members.indexOf(value), 1)[0]);
        }

        return focus = value;
    }
}

class GallerySubState extends FlxSubState
{
    public var photo:GalleryPhoto;

    public function new()
    {
        super(0x88000000);
    }

    override public function create():Void
    {
        // Add ui stuff here
    }

    public function reset(newPhoto:GalleryPhoto):GallerySubState
    {
        if(photo != null)
            remove(photo);

        photo = newPhoto;
        add(photo);

        return this;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.keys.justReleased.ESCAPE)
            close();
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

        FlxMouseEvent.add(this, null, onUp, onOver, onOut, false, true, false);
    }

    public function updateCenter():Void
    {
        centerX = x + width * 0.5;
        centerY = y + height * 0.5;
    }

    function onUp(_):Void
    {
        if(gallery.subState != null) return;

        gallery.isolatePhoto(this);
    }

    function onOver(_):Void
    {
        if(gallery.subState != null) return;

        gallery.focus = this; // Look at me!
    }

    function onOut(_):Void
    {
        if(gallery.subState != null) return;

        gallery.focus = null; // Hovering over whitespace
    }
}