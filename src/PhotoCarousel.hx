package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSignal;

class CarouselPhoto extends FlxSprite
{
    /**
     * Simplified version of `setGraphicSize` that automatically
	 * calls `updateHitbox()` when set
     */
    public var size(default, set):Float = 0.0;

    /**
     * Used to ensure that only one tween from the carousel is 
	 * ever affecting this sprite
     */
    public var transitionTween:FlxTween;

	public var spinning:Bool = false;

	public var meta:Dynamic;

	override public function destroy():Void
	{
		transitionTween = null;
	}

    @:noCompletion function set_size(value:Float):Float
    {
        scale.set(value / frameWidth, value / frameHeight);
        updateHitbox();

        return size = value;
    }   
}

typedef CarouselItem = {
	var sprite:CarouselPhoto;
	var x:Float;
	var y:Float;
	var size:Float;
}

class PhotoCarousel extends FlxTypedGroup<CarouselPhoto>
{
    public static inline var PHOTO_SIZE:Int = 115;

    /**
     * All the positions used in positioning the photos
     */
    public var positions:Array<CarouselItem> = [];

	public var centerX:Float = 0;

	public var centerY:Float = 0;

	//To-do: Make the carousel resizable

	/**
	 * The width of the ellipse created by the carousel
	 */
	public var radiusX(default, null):Float;

	 /**
	  * The height of the ellipse created by the carousel
	  */
	public var radiusY(default, null):Float;

	public var onSpin:FlxSignal;
	public var frontPhotoChanged:FlxTypedSignal<CarouselPhoto->Void>;

    public function new(size:Int, centerX:Float, centerY:Float, radiusX:Float, radiusY:Float)
    {
        super(size);

		this.centerX = centerX;
		this.centerY = centerY;
		this.radiusX = radiusX;
		this.radiusY = radiusY;

		for(i in 0...size)
		{
			var theta = 2 * i * Math.PI / size;
			var dx = radiusX * Math.sin(theta);
			var dy = radiusY * Math.cos(theta);
			var dz = -Math.cos(theta);

			positions.push({
				sprite: null, 
				x: dx,
				y: dy,
				size: PHOTO_SIZE / Math.pow(2, dz)
			});
		}

		onSpin = new FlxSignal();
		frontPhotoChanged = new FlxTypedSignal();
    }

	/**
	 * Smoothly shifts the positions and sizes of each photo
	 * 
	 * @param	CCW	whether or not to spin the wheel counter-clockwise
	 */
	public function spin(direction:WheelDirection):Void
	{
		// Make a new array with the sprites shifted left/right one
		var shifted = [for(obj in positions) obj.sprite];
		shifted = shifted.concat(shifted.splice(0, (direction == COUNTER_CLOCKWISE ? shifted.length - 1 : 1)));

		for(i in 0...positions.length)
		{
			if(shifted[i] == null) continue;

			var sprite = positions[i].sprite = shifted[i];
			var item = positions[i];

			if(sprite.transitionTween != null)
			{
				sprite.transitionTween.cancel();

				if(sprite.spinning) // Immedately move to intended position
				{
					var lastItem = null;
					if(direction == COUNTER_CLOCKWISE)
					{
						lastItem = positions[i - 1];
						if(lastItem == null)
							lastItem = positions[length - 1];
					}
					else
					{
						lastItem = positions[i + 1];
						if(lastItem == null)
							lastItem = positions[0];
					}

					sprite.size = lastItem.size;
					sprite.x = centerX + lastItem.x - sprite.size * 0.5;
					sprite.y = centerY + lastItem.y - sprite.size * 0.5;
				}
			}

			sprite.spinning = true;
			sprite.transitionTween = FlxTween.tween(sprite, {
				x: centerX + item.x - item.size * 0.5, 
				y: centerY + item.y - item.size * 0.5,
				size: item.size
			}, 0.4, {
				ease: FlxEase.quadOut,
				onUpdate: (_) -> members.sort((s1, s2) -> Std.int(s1.size - s2.size)),
				onComplete: (_) -> {
					sprite.transitionTween = null;
					sprite.spinning = false;

					if(i == 0)
						frontPhotoChanged.dispatch(positions[0].sprite);
				}
			});
		}

		onSpin.dispatch();
	}

	override public function destroy():Void
	{
		super.destroy();

		positions = null;
	}
}

enum WheelDirection 
{
	CLOCKWISE;
	COUNTER_CLOCKWISE;
}