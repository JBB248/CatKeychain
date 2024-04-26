package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;

import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;

class GalleryState extends FlxTransitionableState
{
    public var target:FlxObject;

    public function new() 
    {
        super();
    }

    override public function create():Void
    {
        super.create();

        var gallery = AssetPaths.getGallery();

        if(gallery.length <  1)
        {
            var cat = new FlxSprite();
            cat.loadGraphic(AssetPaths.getEmbeddedImage("default-photo.png"));
            cat.screenCenter();

            add(cat);
        }
        else
        {
            var matrix = [[]];
            var row = 0;
            var width = 0.0;
            for(photo in gallery)
            {
                var sprite = new FlxSprite().loadGraphic(photo);
                sprite.setGraphicSize(0, FlxG.height / 3);
                sprite.updateHitbox();

                if(sprite.width + width > FlxG.width)
                {
                    matrix.push([]);
                    row++;
                    width = 0;
                }

                width += sprite.width;
                matrix[matrix.length - 1].push(sprite);
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
                    add(photo);
                }
            }

            target = new FlxObject(0, 0, FlxG.width, FlxG.height);

            FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height / 3 * matrix.length);
            FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height / 3 * matrix.length);
            FlxG.camera.follow(target, NO_DEAD_ZONE, 0.5);

            FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
            FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
        }
    }

    function onScroll(event:MouseEvent):Void
    {
        target.y += event.delta * 30;
        if(target.y < FlxG.worldBounds.y)
            target.y = 0;
        else if(target.y + target.height > FlxG.worldBounds.height)
            target.y = FlxG.worldBounds.height - target.height;
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

        FlxG.collide(target, null);
    }
}