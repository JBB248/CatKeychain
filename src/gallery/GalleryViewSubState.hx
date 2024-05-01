package gallery;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.util.FlxDestroyUtil;

import lime.tools.Orientation;

import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;

class GalleryViewSubState extends FlxSubState
{
    // To-do: this is a duplicate. Maybe make a utility class
    public var mintTextFormat:FlxTextFormatMarkerPair = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF60D4A6), "@");

    public var parent:GalleryState;

    public var orientation:Orientation = LANDSCAPE;

    public var photo:GalleryPhoto;
    public var photoPosition:{
        var x:Float;
        var y:Float;
        var scale:Float;
    };

    public var textBox:FlxSprite;
    public var testText:FlxText;
    public var description:FlxTypeText;

    public var viewCam:FlxCamera;
    public var filters:Array<BitmapFilter>;

    public function new(parent:GalleryState)
    {
        super();

        this.parent = parent;
        this.photoPosition = {x: 0, y:0, scale: 1};

        viewCam = FlxG.cameras.add(new FlxCamera(), false);
        viewCam.bgColor = 0;

        filters = [new BlurFilter(6, 6, 1)];

        openCallback = onOpen;
        closeCallback = onClose;
    }

    override public function create():Void
    {
        textBox = new FlxSprite(0, FlxG.width + 20).makeGraphic(1, 1, 0xFF2C2E39);
        textBox.alpha = 0.6;
        textBox.cameras = [viewCam];
        testText = new FlxText(0, 0, 1);
        description = new FlxTypeText(0, 0, 1, "Neko");
        description.cameras = [viewCam];

        FlxG.watch.add(description, "height");
        FlxG.watch.add(testText, "height");

        add(textBox);
        add(description);
    }

    public function reset(newPhoto:GalleryPhoto):GalleryViewSubState
    {
        photo = newPhoto;
        photoPosition.x = photo.x;
        photoPosition.y = photo.y;
        photoPosition.scale = photo.scale.x / 1.2;
        photo.isolate();
        photo.cameras = [viewCam];
        add(photo);

        return this;
    }

    function onOpen():Void
    {
        viewCam.bgColor = 0xBB000000;
        FlxG.camera.filters = filters;

        orientation = photo.frameWidth > photo.frameHeight ? LANDSCAPE : PORTRAIT;

        var name = photo.data.breeds[0].name;
        var origin = photo.data.breeds[0].origin;
        var temperament = photo.data.breeds[0].temperament;
        var desc = photo.data.breeds[0].description;
        var displayText = '@Cat name:@ ${name}\n\n' 
				+ '@Origin:@ ${origin}\n\n'
				+ '@Temperament:@ ${temperament}\n\n'
				+ '@Description:@ ${desc}';

        if(orientation == LANDSCAPE)
        {
            var scaledHeight = photo.frameHeight * (GalleryPhoto.LANDSCAPE_WIDTH / photo.frameWidth);
            var boxHeight = FlxG.height - scaledHeight - 15;
            textBox.x = 15;
            textBox.y = scaledHeight + 30;
            textBox.setGraphicSize(FlxG.width - 30, boxHeight);
            textBox.updateHitbox();
        }
        else
        {
            var scaledWidth = photo.frameWidth * (GalleryPhoto.PORTRAIT_HEIGHT / photo.frameHeight);
            var boxWidth = FlxG.width - scaledWidth - 30;

            testText.fieldWidth = boxWidth - 8;
            testText.applyMarkup(displayText, [mintTextFormat]);

            textBox.setGraphicSize(boxWidth, testText.height + 8);
            textBox.updateHitbox();

            textBox.x = scaledWidth + 30;
            textBox.y = 15;
        }
        
        description.x = textBox.x + 4;
        description.y = textBox.y + 4;
        description.fieldWidth = textBox.width - 8;
        description.applyMarkup(displayText, [mintTextFormat]);
        description.start(0.01, true, false, [SPACE]);
    }

    function onClose():Void
    {
        viewCam.bgColor = 0;
        FlxG.camera.filters = null;

        photo.cameras = null;
        photo.deisolate();
        remove(photo);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(FlxG.keys.justReleased.ESCAPE)
            close();
    }

    override public function destroy():Void
    {
        super.destroy();

        viewCam = FlxDestroyUtil.destroy(viewCam);

        parent = null;
        orientation = null;
        photo = null;
        photoPosition = null;
        filters = null;
        testText = FlxDestroyUtil.destroy(testText);
    }
}