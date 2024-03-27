package;

import flixel.FlxG;
import flixel.util.FlxSignal;

import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;

class CatGenerator
{
    public var onCatGenerated(get, null):FlxTypedSignal<BitmapData -> Void>;

    var _request:URLRequest;
    var _loader:URLLoader;
    var _busy:Bool = false;

    public function new()
    {
        _request = new URLRequest("https://api.thecatapi.com/v1/images/search");

        _loader = new URLLoader();
        _loader.dataFormat = URLLoaderDataFormat.TEXT;
        _loader.addEventListener(Event.COMPLETE, onComplete);
        _loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onStatusRecieved);
        _loader.load(_request);
    }

    public function requestCat():Void
    {
        if(_busy)
            return FlxG.log.warn("Cat generator is busy");

        _busy = true;
        _loader.load(_request);
    }

    function onStatusRecieved(event:HTTPStatusEvent):Void
    {
        if(event.status == 200) return;
        
        FlxG.log.warn('HTTP Error code: ${event.status}');
        _busy = false;
    }

    function onComplete(event:Event):Void
    {
        var data = haxe.Json.parse(event.target.data);

        var request = new URLRequest(data[0].url);
        var loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(Event.COMPLETE, onCatLoaded);
        loader.load(request);
    }

    function onCatLoaded(event:Event):Void
    {
        _busy = false;
        onCatGenerated.dispatch(BitmapData.fromBytes(event.target.data));
    }

    @:noCompletion function get_onCatGenerated():FlxTypedSignal<BitmapData->Void>
    {
        return onCatGenerated ??= new FlxTypedSignal();
    }
}