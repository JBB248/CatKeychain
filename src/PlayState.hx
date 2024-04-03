package;

import burst.BurstEncryptor;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;

import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;

import sys.io.File;

typedef CarouselItem = {
	var sprite:FlxSprite;
	var position: {
		var x:Float;
		var y:Float;
		var z:Float;
	}
};

class PlayState extends FlxState
{
	public var text:FlxText;
	public var button:FlxTypedButton<FlxSprite>;

	public var progressBar:FlxBar;
	public var progress(get, never):Float;

	public var photos:FlxTypedGroup<FlxSprite>;
	public var carousel:Array<CarouselItem> = [];
	public var photoCount:Int = 15;
	public var target:Int = 0;

	var photoFrameSize:Float = 50.0;

	public var generator:CatGenerator;
	public var ready:Bool = false;

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

		/*********************** Encryption ***********************/

		pixels = BitmapData.fromFile("data/Ball.png");

		var encrypted = BurstEncryptor.encrypt(pixels, "Ball attack");
		File.saveBytes("data/Test.png", encrypted.encode(encrypted.rect, new PNGEncoderOptions()));

		encrypted = BitmapData.fromFile("data/Test.png");
		var message = BurstEncryptor.decrypt(encrypted);
	}

	function catGenerated(pixels:BitmapData):Void
	{
		if(photos.length == 0)
			pixels.fillRect(new Rectangle(0, 0, pixels.width * 0.5, pixels.height * 0.5), 0xFFFF0000);

		var sprite = new FlxSprite().loadGraphic(pixels);
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
		var r = 100;
		var i = target;

		do
		{
			var theta = 2 * i * Math.PI / photoCount;
			var dx = r * Math.sin(theta);
			var dy = r * Math.cos(theta);
			var dz = r * -Math.cos(theta) / photoFrameSize;

			carousel.push({
				sprite: photos.members[i], 
				position: {
					x: cx + dx,
					y: cy + dy,
					z: photoFrameSize / Math.pow(2, dz)
				}
			});

			i = FlxMath.wrap(i + 1, 0, photoCount - 1);
		}
		while(i != target);

		var newMembers = carousel.copy();
		newMembers.sort((obj1, obj2) -> Std.int(obj1.position.z - obj2.position.z));
		photos.members = [for(obj in newMembers) obj.sprite];

		ready = true;
	}

	function setSpriteZ(sprite:FlxSprite, value:Float):Float
	{
		if(sprite.frameWidth > sprite.frameHeight)
			sprite.setGraphicSize(value);
		else
			sprite.setGraphicSize(0, value);
		sprite.updateHitbox();

		return value;
	}

	var delay = 0.4;
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if(ready)
		{
			delay -= elapsed;
			if(delay <= 0)
			{
				delay = 0.4;
				spinWheel(false);
			}
		}
	}

	function spinWheel(CCW:Bool = false)
	{
		var shifted = [for(obj in carousel) obj.sprite];
		shifted = shifted.concat(shifted.splice(0, (CCW ? shifted.length - 1 : 1)));

		for(i in 0...carousel.length)
		{
			var sprite = carousel[i].sprite = shifted[i];
			var position = carousel[i].position;

			setSpriteZ(sprite, position.z);
			sprite.setPosition(position.x - sprite.width * 0.5, position.y - sprite.height * 0.5);
		}

		var newMembers = carousel.copy();
		newMembers.sort((obj1, obj2) -> Std.int(obj1.position.z - obj2.position.z));
		photos.members = [for(obj in newMembers) obj.sprite];
	}

	@:noCompletion function get_progress():Float
	{
		return photos.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}
