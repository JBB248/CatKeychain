package browse;

import AppUtil.*;
import MainMenuState.MenuButton;

import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxSpriteContainer;
import flixel.text.FlxText;

class DownloadMenu extends FlxSpriteContainer
{
    public var backdrop:FlxSprite;
    public var text:FlxText;
    public var nameInput:FlxInputText;
    public var notesInput:FlxInputText;
    public var button:MenuButton;

    public var hasFocus(get, never):Bool;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);

		text = new FlxText(4, 4, 36, "Name:\n\nNote:");
		nameInput = new FlxInputText(text.x + text.width + 2, text.y, 145);
		notesInput = new FlxInputText(nameInput.x, nameInput.y + nameInput.height + 4, 145);
		notesInput.maxLength = 24;
		var note = new FlxText(notesInput.x - 1, notesInput.y + notesInput.height + 2, 145, "- 24 character max");

		button = new MenuButton(text.x, note.y + note.height + 4, "Download", [NAVY, SOFT_WHITE, SOFT_NAVY]);
		button.onUp.callback = () -> {
			// Save photo
		};

        backdrop = new FlxSprite().makeGraphic(192, Std.int(button.y + button.height + 4), SOFT_NAVY);

		add(backdrop);
		add(text);
		add(nameInput);
		add(notesInput);
		add(note);
		add(button);
    }

    @:noCompletion function get_hasFocus():Bool
    {
        return nameInput.hasFocus || notesInput.hasFocus;
    }

    override public function get_width():Float
    {
        return backdrop.width;
    }

    override public function get_height():Float
    {
        return backdrop.height;
    }
}