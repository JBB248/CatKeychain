package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;

import openfl.events.MouseEvent;

class GalleryState extends FlxTransitionableState
{
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

            FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
        }
    }

    function onScroll(event:MouseEvent):Void
    {
        
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(MainMenuState.new);
    }
}