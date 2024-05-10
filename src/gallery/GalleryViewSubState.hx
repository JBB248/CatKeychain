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
        textBox = new FlxSprite(0, FlxG.width + 20).makeGraphic(1, 1, AppUtil.SOFT_BLACK);
        textBox.alpha = 0.8;
        textBox.cameras = [viewCam];
        testText = new FlxText(0, 0, 1);
        description = new FlxTypeText(0, 0, 1, "Neko");
        description.cameras = [viewCam];

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

        var displayText = new StringBuf();

        if(photo.data.user_note != null && photo.data.user_nickname.length > 0)
            displayText.add('@Nickname:@ ${photo.data.user_nickname}' + (orientation == LANDSCAPE ? ", " : "\n\n"));
        else
            displayText.add("@Nickname:@ none provided" + (orientation == LANDSCAPE ? ", " : "\n\n"));
        
        if(photo.data.user_note != null && photo.data.user_note.length > 0)
            displayText.add('@Note:@ ${photo.data.user_note}\n\n\n');
        else
            displayText.add("@Note:@ none provided\n\n\n");

        if(photo.data.breeds != null && photo.data.breeds.length > 0)
        {
            displayText.add('@Breed:@ ${photo.data.breeds[0].name}' + (orientation == LANDSCAPE ? ", " : "\n\n"));
            displayText.add('@Origin:@ ${photo.data.breeds[0].origin}\n\n');
            displayText.add('@Temperament:@ ${photo.data.breeds[0].temperament}\n\n');
            displayText.add('@Description:@ ${photo.data.breeds[0].description}\n\n');
        }
        else
        {
            displayText.add("No data available");
        }


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
            testText.applyMarkup(displayText.toString(), [parent.textFormat]);

            textBox.setGraphicSize(boxWidth, testText.height + 8);
            textBox.updateHitbox();

            textBox.x = scaledWidth + 30;
            textBox.y = 15;
        }
        
        description.x = textBox.x + 4;
        description.y = textBox.y + 4;
        description.fieldWidth = textBox.width - 8;
        description.applyMarkup(displayText.toString(), [parent.textFormat]);
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

    public inline function checkMouse():Bool
    {
        return FlxG.mouse.justReleased && !FlxG.mouse.overlaps(photo) && !FlxG.mouse.overlaps(textBox);
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