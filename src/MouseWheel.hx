package;

import flixel.FlxG;
import openfl.events.MouseEvent;

/**
 * Very bare-bones class to insert code to mouse wheel listener events 
 * after execution that prevents webpages from scrolling while the app is in focus
 */
class MouseWheel
{
    var listeners:Array<MouseEvent->Void> = [];

    public function new()
    {
        FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseScroll);
    }

    public function addEventListener(listener:MouseEvent->Void):Void
    {
        listeners.push(listener);
    }

    public function removeEventListener(listener:MouseEvent->Void):Void
    {
        listeners.remove(listener);
    }

    function onMouseScroll(event:MouseEvent):Void
    {
        for(listener in listeners)
        {
            listener(event);
        }

        // Prevent webpage from scrolling
        event.stopImmediatePropagation();
        event.stopPropagation();
        #if (html5 || android)
        event.preventDefault();
        #end
    }
}