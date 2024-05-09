package gallery;

import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil;

class GalleryState extends FlxTransitionableState
{
    public var camTarget:FlxObject;

    public var gallery:FlxTypedGroup<GalleryPhoto>;
    public var filteredByNickname:Array<GalleryPhoto>;
    public var focus(default, set):GalleryPhoto;

    public var searching:Bool = false;
    public var input:FlxInputText;
    public var found:Int = 0;

    public var viewSubState:GalleryViewSubState;

    public function new() 
    {
        super();
    }

    override public function create():Void
    {
        super.create();

        FlxG.cameras.bgColor = AppUtil.SOFT_WHITE;

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
            gallery = new FlxTypedGroup(); // FlxContainer has a child/parent relationship that bothers the substate

            var matrix = [[]];
            var row = 0;
            var width = 0.0;
            for(item in savedGallery)
            {
                var photo = new GalleryPhoto(item.graphic, item.data, this);
                if(photo.width + width + 5 > FlxG.width)
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
                        photo.updatePortrait(last.x + last.width + 5, last.y);
                    else
                        photo.updatePortrait(dx, GalleryPhoto.PHOTO_ROW_HEIGHT * j + j * 5);
                    gallery.add(photo);
                }
            }

            filteredByNickname = gallery.members.filter((photo) -> photo.data.user_nickname != null && photo.data.user_nickname.length > 0);
            input = new FlxInputText(5, 5, 145, null, 8, FlxColor.WHITE, AppUtil.SOFT_NAVY);
            input.fieldBorderColor = AppUtil.NAVY;
            input.fieldBorderThickness = 5;
            input.callback = findPhoto;
            input.scrollFactor.y = 0;
            input.kill();

            camTarget = new FlxObject(0, 0, FlxG.width, FlxG.height);
            viewSubState = new GalleryViewSubState(this);
            destroySubStates = false;

            add(gallery);
            add(input);

            FlxG.worldBounds.set(0, 0, FlxG.width, GalleryPhoto.PHOTO_ROW_HEIGHT * matrix.length + 5 * (matrix.length - 2));
            FlxG.camera.setScrollBounds(FlxG.worldBounds.x, FlxG.worldBounds.width, FlxG.worldBounds.y, FlxG.worldBounds.height);
            FlxG.camera.follow(camTarget, NO_DEAD_ZONE, 0.5);
        }
    }

    override public function finishTransIn():Void
    {
        if(gallery != null)
        {
            gallery.forEach((photo) -> photo.activateListeners());
        }
        
        super.finishTransIn();
    }

    public function isolatePhoto(photo:GalleryPhoto):Void
    {
        openSubState(viewSubState.reset(photo));
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        final keys = FlxG.keys;
        if(searching)
        {
            if(keys.justReleased.ESCAPE || (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(input)))
            {
                searching = false;
                input.kill();

                for(photo in gallery.members)
                {
                    if(photo == focus) continue;

                    photo.alpha = 1.0;
                    photo.highlighted = false;
                }
            }
        }
        else
        {
            if(keys.justReleased.ESCAPE)
            {
                FlxG.switchState(MainMenuState.new);
            }
            if(gallery != null && keys.justReleased.F && keys.pressed.CONTROL)
            {
                searching = true;

                input.revive();
                input.hasFocus = true;

                findPhoto(input.text, "open");
            }
        }

        if(gallery != null && camTarget != null)
        {
            // Update scroll
            camTarget.y -= FlxG.mouse.wheel * 40;
            if(camTarget.y < FlxG.worldBounds.y)
                camTarget.y = 0;
            else if(camTarget.y + camTarget.height > FlxG.worldBounds.height)
                camTarget.y = FlxG.worldBounds.height - camTarget.height;
        }
    }

    function findPhoto(text:String, action:String):Void
    {
        found = 0;
        var count = 0;
        for(photo in filteredByNickname)
        {
            var fName = photo.data.user_nickname.substr(0, text.length).toLowerCase();
            var fText = text.toLowerCase();

            if(text.length > 0 && AppUtil.compareTo(fName, fText) == 0)
            {
                count++;
                photo.highlighted = true;
                photo.alpha = 1.0;
            }
            else
            {
                photo.highlighted = false;
                if(photo != focus)
                    photo.alpha = 0.4;
            }
        }
        found = count;
    }

    function inflatePhoto(photo:GalleryPhoto):Void
    {
        // Enlarge new focus to make it stand out
        photo.setGraphicSize(0, GalleryPhoto.PHOTO_ROW_HEIGHT * 1.25);
        photo.updateHitbox();

        photo.x = photo.center.x - photo.width * 0.5;
        photo.y = photo.center.y - photo.height * 0.5;

        // Move new focus to top of draw stack, but below highlighted photos
        final members = gallery.members;
        members.insert(members.length - (found + 1), members.splice(members.indexOf(photo), 1)[0]);
    }

    function deflatePhoto(photo:GalleryPhoto):Void
    {
        // Restore old focus to original size
        photo.x = photo.portrait.x;
        photo.y = photo.portrait.y;
        photo.scale.set(photo.portrait.scale, photo.portrait.scale);
        photo.updateHitbox();
    }

    override public function closeSubState():Void
    {
        focus = null; // Make sure the photo resets, even if it's still being targeted

        super.closeSubState();
    }

    override public function destroy():Void
    {
        focus = null;
        gallery = null;
        input = null;
        filteredByNickname = null;

        super.destroy();

        camTarget = FlxDestroyUtil.destroy(camTarget);
        viewSubState = FlxDestroyUtil.destroy(viewSubState);
    }

    @:noCompletion function set_focus(value:GalleryPhoto):GalleryPhoto
    {
        if(subState == null && focus != null)
        {
            if(!focus.highlighted && searching)
                focus.alpha = 0.4;
            deflatePhoto(focus);
        }

        if(value != null)
        {
            if(searching)
                value.alpha = 1.0;
            inflatePhoto(value);
        }

        return focus = value;
    }
}