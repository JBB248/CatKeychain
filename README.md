<img src="docs/menu-preview.gif" alt="menu-preview" height="480px"/>

A clever app that hides secrets within photos of cats.
<br/>
Photos are downloaded within the app from [TheCatAPI](https://thecatapi.com/).
<br/><br/>
I cannot distribute an executable version (yet), but a demo is available [here](https://jbb248.github.io/CatKeychain/) and the instructions to build it yourself are simple (and listed below).

## Building
If you want to build your own copy or even create your own version, the steps are simple:
<br/><em>Note: the encryption functionality is hidden from github. This is to simply build an app that views cat photos.</em>
<ol>
    <li>
        <a href="https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository">Clone</a> or <a href="https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo">fork</a> this repository (requires <a href="https://git-scm.com/">git</a>) or simply <a href="https://github.com/JBB248/CatGallery/archive/refs/heads/main.zip">download</a> the source code 
    </li>
    <li>
        Download and install <a href="https://haxe.org">Haxe</a>
    </li>
    <li>
        Follow the instructions to <a href="https://haxeflixel.com/documentation/getting-started/">install HaxeFlixel</a>
    </li>
    <li>
        If you aren't going to use Neko, you'll need to set lime up for your OS
        <ul>
            <li>Windows: <a href="https://lime.openfl.org/docs/advanced-setup/windows/">Setup Windows</a></li>
            <li>Windows: <a href="https://lime.openfl.org/docs/advanced-setup/macos/">Setup MacOS</a></li>
            <li>Windows: <a href="https://lime.openfl.org/docs/advanced-setup/linux/">Setup Linux</a></li>
        </ul>
    </li>
    <li>
        Without a key to <a href="https://thecatapi.com/">TheCatAPI</a>, the code will compile into a demo build which will use predetermined photos and data.
        To get around this, get yourself a key, then add <code>-DCAT_API_KEY="YOUR_KEY_HERE"</code> to your build command. (Windows example: <code>lime build windows -DCAT_API_KEY="YOUR_KEY_HERE"</code>)
    </li>
</ol>

### Note:
This is built with Windows and HTML5 in mind.
I do not have the means to test on Mac or Linux, so those builds may not function as expected.

If you have any questions, leave them in the discussions tab.

## Credits
- Downloadable photos are sourced from [TheCatAPI](https://thecatapi.com/)
- Spinning maxwell cat sourced from [r/Catloaf](https://www.reddit.com/r/Catloaf/comments/yrvghr/found_it_the_very_rare_3d_360_degrees_catloaf/)
- Powered by [HaxeFlixel](https://haxeflixel.com)
