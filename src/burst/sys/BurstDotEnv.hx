package burst.sys;

#if BURST_DOTENV
@:file(".env") private class DotEnvFile extends openfl.utils.ByteArray.ByteArrayData { }
#end

/**
 * Helper class to get variables from embedded variables in .env file
 * 
 * _Note:_ A .env file must exist at the project root _AND_ 
 * `BURST_DOTENV` must be flagged for this class to function properly. 
 * Otherwise, the project will throw a missing asset error or all functions _always_ will return null.
 */
class BurstDotEnv
{
    private static var values(null, never):Map<String, String> = [];

    /**
     * Reads and parses .env file
     * 
     * Call this in your main function
     */
    public static function init():Void
    {
        #if BURST_DOTENV
        var content = new DotEnvFile().toString();
        var check = ~/\w+=([A-z0-9\.]+|".+?")/;

        while(check.match(content))
        {
            var data = check.matchedPos();
            var substr = content.substr(data.pos, data.len);
            var eIndex = substr.indexOf("=");
            var key = substr.substring(0, eIndex);
            var value = substr.substring(eIndex + 1);

            values[key] = value;
            content = content.substring(data.len);
        }
        #end
    }

    /**
     * Gets value mapped to `key` from .env file.
     * 
     * If the value does not exist, the result is `null`.
     */
    public static function get(key:String):Null<String>
    {
        return values[key];
    }

    /**
     * Gets value mapped to `key` from .env file and parses it as an integer.
     * 
     * _Note:_ If the value mapped to `key` is a float, the result will be truncated.
     * 
     * If the value does not exist or could not be parsed as an integer, the result is `null`.
     */
    public static function getInt(key:String):Null<Int>
    {
        return Std.parseInt(values[key]);
    }

    /**
     * Gets value mapped to `key` from .env file and parses it as an float.
     * 
     * If the value does not exist or could not be parsed as an float, the result is `null`.
     */
    public static function getFloat(key:String):Null<Float>
    {
        return Std.parseFloat(values[key]);
    }

    /**
     * Gets value mapped to `key` from .env file and parses it as an boolean.
     * 
     * Proper boolean formats for true include `true`, `1`, or `t`, and
     * proper boolean formats for false include `false`, `0`, or `f`.
     * Parsing is case-insensitive.
     * 
     * If the value does not exist or could not be parsed as an boolean, the result is `null`.
     */
    public static function getBool(key:String):Null<Bool>
    {
        var value = values[key];
        if(value != null)
        {
            var lower = value.toLowerCase();
            if(lower == "true" || lower == "1" || lower == "t")
                return true;
            if(lower == "false" || lower == "0" || lower == "f")
                return false;
        }

        return null;
    }
}