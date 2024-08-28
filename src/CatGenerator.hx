package;

import flixel.FlxG;
import flixel.util.FlxSignal;

import haxe.Json;
import haxe.macro.Compiler;

import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.HTTPStatusEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;

/**
 * Generates photos of cats by sending a request to [The Cat API](https://thecatapi.com/).
 * 
 * Photos can be requests using `requestCat`.
 * 
 * _Note:_ Gifs do not function well in openfl, so only jpegs are generated.
 */
class CatGenerator
{
    public static var emptyData:String = "{
        \"breeds\": null,
        \"id\": \"\",
        \"url\": null,
        \"width\": 0,
        \"height\": 0,

        \"image\": null,
        \"user_nickname\": null,
        \"user_note\": null
    }";

    public var onCatGenerated:FlxTypedSignal<CatData->Void>;

    var catLoader:CatLoader;
    var loader:URLLoader;

    var busy:Bool = false;
    var requestCount:Int = 0;

    public function new()
    {
        onCatGenerated = new FlxTypedSignal();

        loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
        loader.addEventListener(Event.COMPLETE, onComplete);
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onStatusRecieved);

        catLoader = new CatLoader(this);
    }

    /**
     * Adds `count` to `requestCount` and begins
     * download immediately if not busy.
     * 
     * When the photo is generated, `onCatGenerated` will be dispatched with
     * the photo alongside other data such as breed information, if it exists.
     */
    public function requestCat(count:Int = 1):Void
    {
        #if DEMO_BUILD
        catLoader.pushRequests(Json.parse(AssetPaths.getData("demo-data.json")), true);
        #else
        requestCount += count;
        if(!busy) getDataFromAPI();
        #end
    }

    function getDataFromAPI():Void
    {
        busy = true;

        var limit = 1;
        var key = Compiler.getDefine("CAT_API_KEY");
        if(requestCount > 1)
        {
            if(key == null)
                limit = 10; // Requests can either be single or batches of ten without an api key
            else
                limit = Std.int(Math.min(100, requestCount)); // Requests can be in batches of up to 100 items with api key
        }
        requestCount -= limit;
        loader.load(new URLRequest(
            "https://api.thecatapi.com/v1/images/search"
            + "?limit=" + limit
            #if !DEMO_BUILD 
            // Without an api key, only ten photos can be requested at a time, data isn't guaranteed, and non-jpegs may be retrieved
            + "&has_breeds=1"
            + "&mime_types=jpg,png"
            + "&api_key=" + Keys.CAT_API_KEY
            #end
        ));
    }

    function onStatusRecieved(event:HTTPStatusEvent):Void
    {
        if(event.status == 200) return; // Success

        // To-do: Handle other HTTP codes
        
        FlxG.log.warn('HTTP Error code: ${event.status}');
        busy = false;
    }

    function onComplete(event:Event):Void
    {
        var response:Array<CatData> = Json.parse(event.target.data);

        catLoader.pushRequests(response);

        if(requestCount > 0)
            getDataFromAPI();
        else
            busy = false;
    }

    public function destroy():Void
    {
        catLoader.destroy();
        if(busy) loader.close();
        onCatGenerated.destroy();

        catLoader = null;
        loader = null;
        onCatGenerated = null;
    }
}

/**
 * Loads images of cats into `CatResponseData` using their url
 */
class CatLoader
{
    public var progress:Float = 1.0;
    public var requests:Array<CatData> = [];

    var generator:CatGenerator;

    var loader:URLLoader;
    var focus:CatData = null;

    var busy:Bool = false;

    public function new(generator:CatGenerator)
    {
        this.generator = generator;

        loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        loader.addEventListener(Event.COMPLETE, dispatchCat);
    }

    /**
     * Appends a request to `requests` and begins image loading if not busy
     */
    public function pushRequests(newRequests:Array<CatData>, ?local:Bool = false):Void
    {
        if(local)
        {
            for(request in newRequests)
            {
                request.image = @:privateAccess AssetPaths.getGalleryPhoto(request.id).bitmap;
                generator.onCatGenerated.dispatch(request);
            }
        }
        else
        {
            requests = requests.concat(newRequests);

            if(!busy)
            {
                busy = true;
                checkRequests();
            }
        }
    }

    function onProgress(event:ProgressEvent):Void
    {
        progress = event.bytesLoaded / event.bytesTotal;
    }

    function dispatchCat(event:Event):Void
    {
        focus.image = BitmapData.fromBytes(event.target.data);
        generator.onCatGenerated.dispatch(focus);

        checkForNewRequest();
    }

    function checkRequests():Void
    {
        focus = requests.shift();
        if(StringTools.endsWith(focus.url, ".jpg") || StringTools.endsWith(focus.url, ".png"))
        {
            loader.load(new URLRequest(focus.url));
        }
        else
        {
            focus.image = AssetPaths.getImage("default-photo.png", true).bitmap;
            generator.onCatGenerated.dispatch(focus);
            checkForNewRequest();
        }
    }

    function checkForNewRequest():Void
    {
        if(requests.length > 0)
        {
            checkRequests();
        }
        else
        {
            focus = null;
            busy = false;
        }
    }

    public function destroy():Void
    {
        loader = null;
        requests = null;
        focus = null;
        generator = null;
    }
}

typedef CatData = {
    var breeds:Array<CatBreedData>;
    var id:String;
    var url:String;
    var width:Int;
    var height:Int;

    var image:BitmapData;
    var user_nickname:String;
    var user_note:String;
}

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