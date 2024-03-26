package burst.util;

import sys.Http;
import sys.io.File;

class BurstImageUtil
{
    public static function getFromGoogleSearch():Array<String>
    {
        var imageLinks = [];

        var html = Http.requestUrl("https://www.google.com/search?q=cat+photo&tbm=isch&safe=active");
		var output = File.write("data/Test.html", false);
		output.writeString(html);
		output.flush();
		output.close();

        return imageLinks;
    }
}