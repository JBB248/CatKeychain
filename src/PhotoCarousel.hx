package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

typedef CarouselItem = {
	var sprite:CarouselSprite;
	var x:Float;
	var y:Float;
	var size:Float;
}

class PhotoCarousel extends FlxTypedGroup<CarouselSprite>
{
    public static inline var PHOTO_SIZE:Int = 115;

    public var positions:Array<CarouselItem> = [];

    public function new(size:Int)
    {
        super(size);

        var cx = FlxG.width / 2;
		var cy = FlxG.height / 2;

		for(i in 0...size)
		{
			var theta = 2 * i * Math.PI / size;
			var dx = 250 * Math.sin(theta);
			var dy = 80 * Math.cos(theta);
			var dz = -Math.cos(theta);

			positions.push({
				sprite: null, 
				x: cx + dx,
				y: cy + dy - 80,
				size: PHOTO_SIZE / Math.pow(2, dz)
			});
		}
    }

	public function spin(CCW:Bool):Void
	{
		var shifted = [for(obj in positions) obj.sprite];
		shifted = shifted.concat(shifted.splice(0, (CCW ? shifted.length - 1 : 1)));

		for(i in 0...positions.length)
		{
			if(shifted[i] == null) continue;

			var sprite = positions[i].sprite = shifted[i];
			var item = positions[i];

			if(sprite.transitionTween != null)
			{
				sprite.transitionTween.cancel();
				var lastItem = null;
				if(CCW)
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
				sprite.x = lastItem.x - sprite.size * 0.5;
				sprite.y = lastItem.y - sprite.size * 0.5;
			}

			sprite.transitionTween = FlxTween.tween(sprite, {
				x: item.x - item.size * 0.5, 
				y: item.y - item.size * 0.5,
				size: item.size
			}, 0.4, {
				ease: FlxEase.quadOut,
				onUpdate: (tween) -> members.sort((s1, s2) -> Std.int(s1.size - s2.size)),
				onComplete: (tween) -> sprite.transitionTween = null
			});
		}
	}
}