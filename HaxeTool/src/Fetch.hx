import js.*;

@:jsRequire("node-fetch")
extern class Fetch {
    @:selfCall
    static public function fetch(args:haxe.extern.Rest<Dynamic>):Promise<Dynamic>;
}