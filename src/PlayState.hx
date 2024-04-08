package;

import burst.BurstEncryptor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.events.KeyboardEvent;

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
		progressBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.4), 10, this, "progress", 0, 1);
		progressBar.createFilledBar(0xFFCD5D5D, 0xFF0F99EE);
		// progressBar.screenCenter();
		// progressBar.visible = false;
		
		fillCarousel();

		photos = new FlxTypedGroup(photoCount);
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
		sprite.antialiasing = true;
		sprite.loadGraphic(pixels);
		photos.add(sprite);

		var item = carousel[0];
		item.sprite = sprite;
		sprite.x = item.x - sprite.width * 0.5;
		sprite.y = item.y - sprite.height * 0.5;
		sprite.z = item.z;

		spinWheel(true);

		// if(photos.length == photoCount)
			// Notify that the carousel is ready
	}

	function fillCarousel():Void
	{
		var cx = FlxG.width / 2;
		var cy = FlxG.height / 2;

		for(i in 0...photoCount)
		{
			var theta = 2 * i * Math.PI / photoCount;
			var dx = 250 * Math.sin(theta);
			var dy = 80 * Math.cos(theta);
			var dz = -Math.cos(theta);

			carousel.push({
				sprite: null, 
				x: cx + dx,
				y: cy + dy - 100,
				z: photoFrameSize / Math.pow(2, dz)
			});
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
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
			if(shifted[i] == null) continue;

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
				onUpdate: (tween) -> photos.members.sort((s1, s2) -> Std.int(s1.z - s2.z)),
				onComplete: (tween) -> sprite.transitionTween = null
			});
		}
	}

	@:noCompletion function get_progress():Float
	{
		return photos.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}