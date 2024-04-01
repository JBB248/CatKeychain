package;

import burst.sys.BurstDotEnv;

import flixel.FlxG;
import flixel.util.FlxSignal;

import haxe.Json;

import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;

class CatGenerator
{
    public var onCatGenerated(get, null):FlxTypedSignal<BitmapData->Void>;

    var loader:URLLoader;
    public var catLoader:CatLoader;

    var busy:Bool = false;
    var requestCount:Int = 0;
    var links:Array<String> = [];

    public function new()
    {
        loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
        loader.addEventListener(Event.COMPLETE, onComplete);
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onStatusRecieved);

        catLoader = new CatLoader(this);
    }

    public function requestCat(count:Int = 1):Void
    {
        requestCount += count;

        if(!busy)
            getDataFromServer();
    }

    function getDataFromServer():Void
    {
        busy = true;

        var limit = Std.int(Math.min(100, requestCount));
        requestCount -= limit;
        loader.load(new URLRequest(
            "https://api.thecatapi.com/v1/images/search"
            + "?limit=" + limit
            + "&mime_types=jpg"
            + "&api_key=" + BurstDotEnv.get("CAT_API_KEY")
        ));
    }

    function onStatusRecieved(event:HTTPStatusEvent):Void
    {
        if(event.status == 200) return;
        
        FlxG.log.warn('HTTP Error code: ${event.status}');
        busy = false;
    }

    function onComplete(event:Event):Void
    {
        var response:CatResponseData = Json.parse(event.target.data);

        catLoader.pushRequests([for(object in response) object.url]);

        if(requestCount > 0)
            getDataFromServer();
        else
            busy = false;
    }

    @:noCompletion function get_onCatGenerated():FlxTypedSignal<BitmapData->Void>
    {
        return onCatGenerated ??= new FlxTypedSignal();
    }
}

class CatLoader
{
    public var progress:Float = 0.0;

    var loader:URLLoader;
    var requests:Array<String> = [];
    var busy:Bool = false;

    var generator:CatGenerator;

    public function new(generator:CatGenerator)
    {
        this.generator = generator;

        loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        loader.addEventListener(Event.COMPLETE, dispatchCat);
    }

    public function pushRequests(newRequests:Array<String>):Void
    {
        requests = requests.concat(newRequests);

        if(!busy)
        {
            busy = true;
            loader.load(new URLRequest(requests.shift()));
        }
    }

    function onProgress(event:ProgressEvent):Void
    {
        progress = event.bytesLoaded / event.bytesTotal;
    }

    function dispatchCat(event:Event):Void
    {
        generator.onCatGenerated.dispatch(BitmapData.fromBytes(event.target.data));

        if(requests.length > 0)
            loader.load(new URLRequest(requests.shift()));
        else
            busy = false;
    }
}

typedef CatResponseData = Array<{
    var breeds:Array<CatBreedData>;
    var id:String;
    var url:String;
    var width:Int;
    var height:Int;
}>;

typedef CatBreedData = {
    var weight: {
        var imperial:String;
        var metric:String;
    };
    var id:String;
    var name:String;
    var cfa_url:String;
    var vetstreet_url:String;
    var temperament:String;
    var origin:String;
    var country_codes:String;
    var country_code:String;
    var description:String;
    var life_span:String;
    var indoor:Int; // To-do: see if "0" will parse as a boolean
    var lap:Int;
    var alt_names:String;
    var adaptability:Int;
    var affection_level:Int;
    var child_friendly:Int;
    var dog_friendly:Int;
    var energy_level:Int;
    var grooming:Int;
    var health_issues:Int;
    var intelligence:Int;
    var shedding_level:Int;
    var social_needs:Int;
    var stranger_friendly:Int;
    var vocalisation:Int;
    var experimental:Int;
    var hairless:Int;
    var natural:Int;
    var rare:Int;
    var rex:Int;
    var suppressed_tail:Int;
    var short_legs:Int;
    var wikipedia_url:String;
    var hypoallergenic:Int;
    var reference_image_id:String;
};