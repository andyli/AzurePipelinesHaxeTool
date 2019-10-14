package azure_pipelines_tool_lib;

import haxe.extern.Rest;
import js.Promise;

@:jsRequire("azure-pipelines-tool-lib/tool")
extern class Tool {
    static public function debug(args:Rest<Dynamic>):Dynamic;
    static public function prependPath(args:Rest<Dynamic>):Dynamic;
    static public function isExplicitVersion(args:Rest<Dynamic>):Dynamic;
    static public function cleanVersion(args:Rest<Dynamic>):Dynamic;
    static public function evaluateVersions(versions:Array<String>, versionSpec:String):String;
    static public function findLocalTool(toolName:String, versionSpec:String, ?arch:String):Dynamic;
    static public function findLocalToolVersions(toolName:String, ?arch:String):Dynamic;
    static public function downloadTool(fileUrl:String):Promise<String>;
    static public function cacheDir(sourceDir:String, tool:String, version:String, ?arch:String):Promise<String>;
    static public function cacheFile(args:Rest<Dynamic>):Dynamic;
    static public function extract7z(args:Rest<Dynamic>):Promise<String>;
    static public function extractTar(args:Rest<Dynamic>):Promise<String>;
    static public function extractZip(args:Rest<Dynamic>):Promise<String>;
    static public function scrape(args:Rest<Dynamic>):Dynamic;
}