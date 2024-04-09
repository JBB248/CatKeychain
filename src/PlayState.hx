package;

import CatGenerator;
import burst.BurstEncryptor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
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
		progressBar = new FlxBar(0, 0, null, 16 * 15, 15, this, "progress", 0, 1);
		progressBar.createFilledBar(0xFFFF3535, 0xFF0F99EE);
		// progressBar.screenCenter();
		// progressBar.visible = false;

		var graphic = FlxG.bitmap.create(30, 30, 0xFFFFB6CC);
		graphic.bitmap.fillRect(new Rectangle(0, 0, 15, 15), 0xFFD4608E);
		graphic.bitmap.fillRect(new Rectangle(15, 15, 15, 15), 0xFFD4608E);

		var backdrop = new FlxBackdrop(graphic);

		fillCarousel();

		photos = new FlxTypedGroup(photoCount);
		generator = new CatGenerator();
		generator.onCatGenerated.add(catGenerated);
		generator.requestCat(photoCount);

		text = new FlxText(40, FlxG.height * 0.5 + 100);

		add(backdrop);
		add(photos);
		add(text);
		add(progressBar);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);

		/*********************** Encryption ***********************/

		pixels = BitmapData.fromFile("data/Ball.png");

		var encrypted = BurstEncryptor.encrypt(pixels, "Ball attack");
		File.saveBytes("data/Test.png", encrypted.encode(encrypted.rect, new PNGEncoderOptions()));

		encrypted = BitmapData.fromFile("data/Test.png");
		var message = BurstEncryptor.decrypt(encrypted);
	}

	function catGenerated(data:CatResponseData):Void
	{
		var sprite = new CarouselSprite();
		sprite.antialiasing = true;
		sprite.loadGraphic(data.image);
		photos.add(sprite);

		trace(data.breeds);

		text.text = Std.string(data.breeds);

		var item = carousel[0];
		item.sprite = sprite;
		sprite.x = item.x - sprite.width * 0.5;
		sprite.y = item.y - sprite.height * 0.5;
		sprite.z = item.z;

		spinWheel(true);
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
				y: cy + dy - 80,
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

			case FlxKey.DOWN:
				isolatePhoto();
			case FlxKey.UP:
				deisolatePhoto();
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

				sprite.z = lastItem.z;
				sprite.x = lastItem.x - sprite.width * 0.5;
				sprite.y = lastItem.y - sprite.height * 0.5;
			}

			sprite.transitionTween = FlxTween.tween(sprite, {
				x: item.x - item.z * 0.5, 
				y: item.y - item.z * 0.5,
				z: item.z
			}, 0.4, {
				ease: FlxEase.quadOut,
				onUpdate: (tween) -> photos.members.sort((s1, s2) -> Std.int(s1.z - s2.z)),
				onComplete: (tween) -> sprite.transitionTween = null
			});
		}
	}

	function isolatePhoto():Void
	{
		var sprite = carousel[0].sprite;

		FlxTween.tween(sprite, {x: FlxG.width * 0.5 - (carousel[0].z + 100) * 0.5, y: 40, z: carousel[0].z + 100}, 0.8, {ease: FlxEase.sineIn});

		for(i in 1...photoCount)
		{
			var item = carousel[i];
			FlxTween.tween(item.sprite, {y: item.y - item.z * 0.5 - FlxG.height}, 0.8, {ease: FlxEase.backIn, startDelay: i / 100});
		}
	}

	function deisolatePhoto():Void
	{
		for(i in 0...photoCount)
		{
			var item = carousel[i];
			FlxTween.tween(item.sprite, {x: item.x - item.z * 0.5, y: item.y - item.z * 0.5, z: item.z}, 0.8, {ease: FlxEase.backOut, startDelay: i / 100});
		}
	}

	@:noCompletion function get_progress():Float
	{
		return photos.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}