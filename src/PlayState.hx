package;

import openfl.geom.Rectangle;
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

import sys.io.File;

class PlayState extends FlxState
{
	public var text:FlxText;
	public var button:FlxTypedButton<FlxSprite>;

	public var progressBar:FlxBar;
	public var progress(get, never):Float;

	public var photos:FlxTypedGroup<FlxSprite>;
	public var photoCount:Int = 15;
	public var target:Int = 0;

	var photoFrameSize:Float = 50.0;

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

			var sprite = photos.members[i];
			setSpriteZ(sprite, dz);
			sprite.x = cx + dx - sprite.width / 2;
			sprite.y = cy + dy - sprite.height / 2;

			i = FlxMath.wrap(i + 1, 0, photoCount - 1);
		}
		while(i != target);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	function setSpriteZ(sprite:FlxSprite, value:Float):Void
	{
		if(sprite.frameWidth > sprite.frameHeight)
			sprite.setGraphicSize(photoFrameSize / Math.pow(2, value));
		else
			sprite.setGraphicSize(0, photoFrameSize / Math.pow(2, value));

		sprite.updateHitbox();
	}

	@:noCompletion function get_progress():Float
	{
		return photos.length / photoCount + (generator.catLoader.progress < 1 ? generator.catLoader.progress / photoCount : 0);
	}
}
