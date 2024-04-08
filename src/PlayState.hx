package;

import burst.BurstEncryptor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.events.KeyboardEvent;
import openfl.geom.Rectangle;

import sys.io.File;

typedef CarouselItem = {
	var sprite:CarouselSprite;
	var x:Float;
	var y:Float;
	var z:Float;
}

class PlayState extends FlxState
{
	public var text:FlxText;
	public var button:FlxTypedButton<FlxSprite>;

	public var progressBar:FlxBar;
	public var progress(get, never):Float;

	public var photos:FlxTypedGroup<CarouselSprite>;
	public var carousel:Array<CarouselItem> = [];
	public var photoCount:Int = 15;

	var photoFrameSize:Float = 115.0;

	public var generator:CatGenerator;

	var pixels:BitmapData;

	override public function create():Void
	{
		photos = new FlxTypedGroup(photoCount);

		progressBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.4), 10, this, "progress", 0, 1);
		progressBar.createFilledBar(0xFFCD5D5D, 0xFF0F99EE);
		// progressBar.screenCenter();
		// progressBar.visible = false;

		generator = new CatGenerator();
		generator.onCatGenerated.add(catGenerated);
		generator.requestCat(photoCount);

		add(photos);
		add(progressBar);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);

		/*********************** Encryption ***********************/

		pixels = BitmapData.fromFile("data/Ball.png");

		var encrypted = BurstEncryptor.encrypt(pixels, "Ball attack");
		File.saveBytes("data/Test.png", encrypted.encode(encrypted.rect, new PNGEncoderOptions()));

		encrypted = BitmapData.fromFile("data/Test.png");
		var message = BurstEncryptor.decrypt(encrypted);
	}

	function catGenerated(pixels:BitmapData):Void
	{
		var sprite = new CarouselSprite();
		sprite.loadGraphic(pixels);
		sprite.antialiasing = true;
		if(sprite.frameWidth > sprite.frameHeight)
			sprite.setGraphicSize(photoFrameSize);
		else
			sprite.setGraphicSize(0, photoFrameSize);

		sprite.updateHitbox();
		sprite.screenCenter();
		photos.add(sprite);

		if(photos.length == photoCount)
			postCatLoad();
	}

	function postCatLoad():Void
	{
		var cx = FlxG.width / 2;
		var cy = FlxG.height / 2;

		for(i in 0...photos.length)
		{
			var theta = 2 * i * Math.PI / photoCount;
			var dx = 250 * Math.sin(theta);
			var dy = 80 * Math.cos(theta);
			var dz = -Math.cos(theta);

			var sprite = photos.members[i];
			var item = {
				sprite: sprite, 
				x: cx + dx,
				y: cy + dy - 100,
				z: photoFrameSize / Math.pow(2, dz)
			};

			carousel.push(item);
			sprite.x = item.x - item.sprite.width * 0.5;
			sprite.y = item.y - item.sprite.height * 0.5;
			sprite.z = item.x;
		}

		spinWheel(true);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	function sortByZ():Void
	{
		var newMembers = carousel.copy();
		newMembers.sort((obj1, obj2) -> Std.int(obj1.sprite.z - obj2.sprite.z));
		photos.members = [for(obj in newMembers) obj.sprite];
	}

	function keyPressed(event:KeyboardEvent):Void
	{
		switch(event.keyCode)
		{
			case FlxKey.LEFT:
				spinWheel(true);
			case FlxKey.RIGHT:
				spinWheel(false);
		}
	}

	function spinWheel(CCW:Bool)
	{
		var shifted = [for(obj in carousel) obj.sprite];
		shifted = shifted.concat(shifted.splice(0, (CCW ? shifted.length - 1 : 1)));

		for(i in 0...carousel.length)
		{
			var sprite = carousel[i].sprite = shifted[i];
			var item = carousel[i];

			if(sprite.transitionTween != null)
			{
				sprite.transitionTween.cancel();
				var lastItem = null;
				if(CCW)
				{
					lastItem = carousel[i - 1];
					if(lastItem == null)
						lastItem = carousel[carousel.length - 1];
				}
				else
				{
					lastItem = carousel[i + 1];
					if(lastItem == null)
						lastItem = carousel[0];
				}

				sprite.x = lastItem.x - sprite.width * 0.5;
				sprite.y = lastItem.y - sprite.height * 0.5;
				sprite.z = lastItem.z;
			}

			sprite.transitionTween = FlxTween.tween(sprite, {
				x: item.x - sprite.width * 0.5, 
				y: item.y - sprite.height * 0.5,
				z: item.z
			}, 0.4, {
				ease: FlxEase.quadOut,
				onUpdate: (tween) -> sortByZ(),
				onComplete: (tween) -> sprite.transitionTween = null
			});
		}
	}

	@:noCompletion function get_progress():Float
	{
		return photos.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}