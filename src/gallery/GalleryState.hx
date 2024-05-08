package gallery;

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

            filteredByNickname = gallery.members.filter((photo) -> photo.data.user_nickname != null && photo.data.user_nickname.length > 0);
            input = new FlxInputText(0, 0, 145);
            input.callback = findPhoto;
            input.kill();
            add(input);

            FlxG.worldBounds.set(0, 0, FlxG.width, GalleryPhoto.PHOTO_ROW_HEIGHT * matrix.length);
            FlxG.camera.setScrollBounds(0, FlxG.width, 0, GalleryPhoto.PHOTO_ROW_HEIGHT * matrix.length);
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
            if(keys.justReleased.ESCAPE)
            {
                searching = false;
                input.kill();

                for(photo in gallery.members)
                {
                    if(photo == focus) continue;

                    deflatePhoto(photo);
                }
            }
        }
        else
        {
            if(keys.justReleased.F && keys.pressed.CONTROL)
            {
                searching = true;
                input.revive();

                findPhoto(input.text, "open");
            }
            else if(keys.justReleased.ESCAPE)
            {
                FlxG.switchState(MainMenuState.new);
            }
        }

        if(camTarget != null)
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
        for(photo in filteredByNickname)
        {
            var fName = photo.data.user_nickname.substr(0, text.length).toLowerCase();
            var fText = text.toLowerCase();

            if(text.length > 0 && AppUtil.compareTo(fName, fText) == 0)
                inflatePhoto(photo);
            else
                deflatePhoto(photo);
        }
    }

    function inflatePhoto(photo:GalleryPhoto):Void
    {
        // Enlarge new focus to make it stand out
        photo.setGraphicSize(0, GalleryPhoto.PHOTO_ROW_HEIGHT * 1.25);
        photo.updateHitbox();

        photo.x = photo.center.x - photo.width * 0.5;
        photo.y = photo.center.y - photo.height * 0.5;

        // Move new focus to top of draw stack
        final members = gallery.members;
        members.push(members.splice(members.indexOf(photo), 1)[0]);
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
        super.destroy();

        viewSubState = FlxDestroyUtil.destroy(viewSubState);
    }

    @:noCompletion function set_focus(value:GalleryPhoto):GalleryPhoto
    {
        if(focus != null && subState == null)
            deflatePhoto(focus);

        if(value != null)
            inflatePhoto(value);

        return focus = value;
    }
}