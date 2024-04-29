package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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
            viewSubState = new GallerySubState(this);
            destroySubStates = false;

            gallery = new FlxTypedGroup(); // FlxContainer has a child/parent relationship that bothers the substate
            add(gallery);

            var matrix = [[]];
            var row = 0;
            var width = 0.0;
            for(graphic in savedGallery)
            {
                var photo = new GalleryPhoto(graphic, this);
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
                        photo.setPortraitPosition(last.x + last.width, FlxG.height / 3 * j);
                    else
                        photo.setPortraitPosition(dx, FlxG.height / 3 * j);
                    gallery.add(photo);
                }
            }

            FlxG.worldBounds.set(0, 0, FlxG.width, GalleryPhoto.photoHeight * matrix.length);
            FlxG.camera.setScrollBounds(0, FlxG.width, 0, GalleryPhoto.photoHeight * matrix.length);
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
            value.setGraphicSize(0, GalleryPhoto.photoHeight * 1.25);
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

class GallerySubState extends FlxSubState
{
    public var parent:GalleryState;

    public var orientation:Orientation = HORIZONTAL;

    public var photo:GalleryPhoto;
    public var photoPosition:{
        var x:Float;
        var y:Float;
        var scale:Float;
    };

    public function new(parent:GalleryState)
    {
        super(0xBB000000);

        this.parent = parent;
        this.photoPosition = {x: 0, y:0, scale: 1};
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
        photoPosition.x = photo.x;
        photoPosition.y = photo.y;
        photoPosition.scale = photo.scale.x / 1.2;
        photo.isolate();
        add(photo);

        orientation = photo.frameWidth > photo.frameHeight ? VERTICAL : HORIZONTAL;

        return this;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.keys.justReleased.ESCAPE)
        {
            photo.deisolate();
            close();
        }
    }
}

enum Orientation
{
    HORIZONTAL;
    VERTICAL;
}

class GalleryPhoto extends FlxSprite
{
    public static inline var photoHeight:Float = 160;

    public var gallery:GalleryState;

    public var portrait:{
        var x:Float;
        var y:Float;
        var scale:Float;
    };

    public var center:FlxPoint = FlxPoint.get();

    var tween:FlxTween;

    public function new(graphic:FlxGraphicAsset, gallery:GalleryState)
    {
        super(graphic);

        this.gallery = gallery;
        this.portrait = {x: 0, y: 0, scale: 1};

        setGraphicSize(0, photoHeight);
        updateHitbox();
    }

    public function activateListeners():Void
    {
        FlxMouseEvent.add(this, null, onUp, onOver, onOut, false, true, false);
    }

    public function setPortraitPosition(x:Float, y:Float):Void
    {
        setPosition(x, y);

        portrait.x = x;
        portrait.y = y;
        portrait.scale = photoHeight / frameHeight;

        center.x = x + width * 0.5;
        center.y = y + height * 0.5;
    }

    public function isolate():Void
    {
        if(tween != null && !tween.finished)
            tween.cancel();

        var values:Dynamic;

        if(frameWidth > frameHeight)
        {
            var scale = (FlxG.height * 0.6 - 20) / frameHeight;
            values = {
                x: FlxG.width * 0.5 - (frameWidth * scale * 0.5),
                y: 20 + gallery.camTarget.y,
                "scale.x": scale,
                "scale.y": scale
            };
        }
        else
        {
            var scale = (FlxG.width * 0.5 - 40) / frameWidth;
            values = {
                x: 20,
                y: FlxG.height * 0.5 - (frameHeight * scale * 0.5) + gallery.camTarget.y,
                "scale.x": scale,
                "scale.y": scale
            };
        }

        tween = FlxTween.tween(this, values, 1.0, {
            ease: FlxEase.quartOut,
            onUpdate: (_) -> {
                updateHitbox();
            }
        });
    }

    public function deisolate():Void
    {
        if(tween != null && !tween.finished)
            tween.cancel();

        tween = FlxTween.tween(this, {
            x: portrait.x,
            y: portrait.y,
            "scale.x": portrait.scale,
            "scale.y": portrait.scale
        }, 0.4, {
            ease: FlxEase.quartOut,
            onUpdate: (_) -> {
                updateHitbox();
            }
        });
    }

    function onUp(_):Void
    {
        if(gallery.subState != null) return;

        gallery.isolatePhoto(this);
    }

    function onOver(_):Void
    {
        if(gallery.subState != null || (tween != null && !tween.finished)) return;

        gallery.focus = this; // Look at me!
    }

    function onOut(_):Void
    {
        if(gallery.subState != null || (tween != null && !tween.finished)) return;

        gallery.focus = null; // Hovering over whitespace
    }

    override public function destroy():Void
    {
        super.destroy();

        portrait = null;
        center = FlxDestroyUtil.put(center);
    }
}