package gallery;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;

class GalleryState extends FlxTransitionableState
{
    public var camTarget:FlxObject;

    public var gallery:FlxTypedGroup<GalleryPhoto>;
    public var filteredByNickname:Array<GalleryPhoto>;
    public var focus(default, set):GalleryPhoto;

    public var textFormat:FlxTextFormatMarkerPair;

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

            textFormat = AppUtil.getIceTextFormat();

            filteredByNickname = gallery.members.filter((photo) -> photo.data.user_nickname != null && photo.data.user_nickname.length > 0);
            input = new FlxInputText(5, 5, 145, null, 8, FlxColor.WHITE, AppUtil.SOFT_NAVY);
            input.fieldBorderColor = AppUtil.NAVY;
            input.fieldBorderThickness = 5;
            input.callback = findPhoto;
            input.scrollFactor.y = 0;
            input.kill();

            var ctrlText = new FlxText();
            ctrlText.applyMarkup("View photo: @CLICK@ | Find photo: @CTRL+F@ | Traverse menu: @Scroll wheel@ | Exit: @ESCAPE@", [textFormat]);
            ctrlText.alignment = CENTER;
            ctrlText.screenCenter(X);
            ctrlText.y = FlxG.height - ctrlText.height;
            ctrlText.scrollFactor.y = 0;

            var ctrlTextBD = new FlxSprite().makeGraphic(FlxG.width, Std.int(ctrlText.height), AppUtil.NAVY);
            ctrlTextBD.screenCenter(X);
            ctrlTextBD.y = FlxG.height - ctrlText.height;
            ctrlTextBD.scrollFactor.y = 0;

            camTarget = new FlxObject(0, 0, FlxG.width, FlxG.height);
            viewSubState = new GalleryViewSubState(this);
            destroySubStates = false;

            add(gallery);
            add(input);
            add(ctrlTextBD);
            add(ctrlText);

            FlxG.worldBounds.set(0, 0, FlxG.width, GalleryPhoto.PHOTO_ROW_HEIGHT * matrix.length + 5 * (matrix.length - 2) + ctrlTextBD.height);
            FlxG.camera.setScrollBounds(FlxG.worldBounds.x, FlxG.worldBounds.width, FlxG.worldBounds.y, FlxG.worldBounds.height);
            FlxG.camera.follow(camTarget, NO_DEAD_ZONE, 0.5);

            FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
            FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
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

        if(gallery != null && FlxG.mouse.justPressed && !FlxG.mouse.overlaps(input))
            hideSearchBar();
    }

    function onKeyReleased(event:KeyboardEvent):Void
    {
        if(subState != null) return;

        switch(event.keyCode)
        {
            case FlxKey.ESCAPE:
                if(searching)
                    hideSearchBar();
                else
                    FlxG.switchState(MainMenuState.new);

            case FlxKey.F:
                if(subState == null && gallery != null && !searching && #if mac event.commandKey #else event.controlKey #end)
                    showSearchBar();
        }
    }

    function onMouseWheel(event:MouseEvent):Void
    {
        if(gallery == null || subState != null) return;

        // Update scroll
        camTarget.y -= event.delta * 40;
        if(camTarget.y < FlxG.worldBounds.y)
            camTarget.y = 0;
        else if(camTarget.y + camTarget.height > FlxG.worldBounds.height)
            camTarget.y = FlxG.worldBounds.height - camTarget.height;
    }

    function showSearchBar():Void
    {
        searching = true;

        input.revive();
        input.hasFocus = true;

        findPhoto(input.text, "open");
    }

    function hideSearchBar():Void
    {
        searching = false;
        input.hasFocus = false;
        input.kill();

        for(photo in gallery.members)
        {
            if(photo == focus) continue;

            photo.alpha = 1.0;
            photo.highlighted = false;
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