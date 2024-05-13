package gallery;

import CatGenerator;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEvent;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil;

class GalleryPhoto extends FlxSprite
{
    public static inline var PHOTO_ROW_HEIGHT:Float = 160;

    public static inline var LANDSCAPE_HEIGHT:Float = 320; // FlxG.height * 0.67; Can't use FlxG properties for constants
    public static inline var PORTRAIT_HEIGHT:Float = 408; // FlxG.height * 0.85;

    public var gallery:GalleryState;

    public var highlighted:Bool = false;

    public var data:CatData;

    public var portrait:{
        var x:Float;
        var y:Float;
        var scale:Float;
    };

    public var center:FlxPoint = FlxPoint.get();

    var tween:FlxTween;

    public function new(graphic:FlxGraphicAsset, data:CatData, gallery:GalleryState)
    {
        super(graphic);

        this.data = data;
        this.gallery = gallery;
        this.portrait = {x: 0, y: 0, scale: 1};

        setGraphicSize(0, PHOTO_ROW_HEIGHT);
        updateHitbox();
    }

    public function activateListeners():Void
    {
        FlxMouseEvent.add(this, null, onUp, onOver, onOut, false, true, false);
    }

    public function updatePortrait(x:Float, y:Float):Void
    {
        setPosition(x, y);

        portrait.x = x;
        portrait.y = y;
        portrait.scale = PHOTO_ROW_HEIGHT / frameHeight;

        center.x = x + width * 0.5;
        center.y = y + height * 0.5;
    }

    public function isolate():Void
    {
        if(tween != null && !tween.finished)
            tween.cancel();

        var values:Dynamic;

        if(frameWidth > frameHeight) // Landscape
        {
            y -= gallery.camTarget.y;
            var scale = LANDSCAPE_HEIGHT / frameHeight;
            values = {
                x: FlxG.width * 0.5 - (frameWidth * scale * 0.5),
                y: 15,
                "scale.x": scale,
                "scale.y": scale
            };
        }
        else
        {
            y -= gallery.camTarget.y;
            var scale = PORTRAIT_HEIGHT / frameHeight;
            values = {
                x: 15,
                y: FlxG.height * 0.5 - (frameHeight * scale * 0.5),
                "scale.x": scale,
                "scale.y": scale
            };
        }

        tween = FlxTween.tween(this, values, 0.6, {
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

        y = gallery.camTarget.y + 15;
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

        data = null;
        portrait = null;
        center = FlxDestroyUtil.put(center);
        tween = null;
    }
}