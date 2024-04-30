package gallery;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil;

class GalleryState extends FlxTransitionableState
{
    public var camTarget:FlxObject;

    public var gallery:FlxTypedGroup<GalleryPhoto>;
    public var focus(default, set):GalleryPhoto;

    public var viewSubState:GalleryViewSubState;

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
            viewSubState = new GalleryViewSubState(this);
            destroySubStates = false;

            gallery = new FlxTypedGroup(); // FlxContainer has a child/parent relationship that bothers the substate
            add(gallery);

            var matrix = [[]];
            var row = 0;
            var width = 0.0;
            for(item in savedGallery)
            {
                var photo = new GalleryPhoto(item.graphic, item.data, this);
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
                        photo.updatePortrait(last.x + last.width, FlxG.height / 3 * j);
                    else
                        photo.updatePortrait(dx, FlxG.height / 3 * j);
                    gallery.add(photo);
                }
            }

            FlxG.worldBounds.set(0, 0, FlxG.width, GalleryPhoto.PHOTO_ROW_HEIGHT * matrix.length);
            FlxG.camera.setScrollBounds(0, FlxG.width, 0, GalleryPhoto.PHOTO_ROW_HEIGHT * matrix.length);
            FlxG.camera.follow(camTarget, NO_DEAD_ZONE, 0.5);
        }
    }

    override public function finishTransIn():Void
    {
        gallery.forEach((photo) -> photo.activateListeners());

        super.finishTransIn();
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
        focus = null; // Make sure the photo resets, even if it's still being targeted

        super.closeSubState();
    }

    override public function destroy():Void
    {
        super.destroy();

        viewSubState = FlxDestroyUtil.destroy(viewSubState);
    }

    @:noCompletion function set_focus(value:GalleryPhoto):GalleryPhoto
    {
        if(focus != null && subState == null)
        {
            // Restore old focus to original size
            focus.x = focus.portrait.x;
            focus.y = focus.portrait.y;
            focus.scale.set(focus.portrait.scale, focus.portrait.scale);
            focus.updateHitbox();
        }

        if(value != null)
        {
            // Enlarge new focus to make it stand out
            value.setGraphicSize(0, GalleryPhoto.PHOTO_ROW_HEIGHT * 1.25);
            value.updateHitbox();

            value.x = value.center.x - value.width * 0.5;
            value.y = value.center.y - value.height * 0.5;

            // Move new focus to top of draw stack
            final members = gallery.members;
            members.push(members.splice(members.indexOf(value), 1)[0]);
        }

        return focus = value;
    }
}