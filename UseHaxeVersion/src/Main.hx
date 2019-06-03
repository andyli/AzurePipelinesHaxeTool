import azure_pipelines_task_lib.Task;
import azure_pipelines_tool_lib.Tool;
import js.Promise;
import js.node.*;
import haxe.io.*;
using StringTools;

class Main {
    static var platform(default, never):String = Os.platform();
    static function haxeUrl(version:String):String {
        var file = switch (platform) {
            case "win32":
                'haxe-${version}-win.zip';
            case "darwin":
                'haxe-${version}-osx.tar.gz';
            case "linux":
                'haxe-${version}-linux64.tar.gz';
            case _:
                throw "unsupported platform: " + platform;
        }
        return 'https://haxe.org/website-content/downloads/${version}/downloads/${file}';
    }

    static function getOnlySubDir(path:String):String {
        switch (sys.FileSystem.readDirectory(path)) {
            case [item] if (sys.FileSystem.isDirectory(Path.join([path, item]))):
                return Path.join([path, item]);
            case items:
                throw '$path should contain only one sub-directory. It now has ${items.join(", ")}.';
        }
    }

    static function acquireHaxe(version:String):Promise<String> {
        var url = haxeUrl(version);
        var fileName = Path.withoutDirectory(url);
        return Tool.downloadTool(url)
            .then(function(downloadPath:String) {
                if (fileName.endsWith(".tar.gz"))
                    return Tool.extractTar(downloadPath);
                else if (fileName.endsWith(".zip"))
                    return Tool.extractZip(downloadPath);
                else
                    throw 'No idea of how to handle $fileName';
            })
            .then(function(extPath:String) {
                var subDir = getOnlySubDir(extPath);
                return Tool.cacheDir(subDir, "haxe", version);
            });
    }

    static function handleHaxeInstallPath(path:String):Void {
        Tool.prependPath(path);
        Task.setVariable("HAXE_STD_PATH", Path.join([path, "std"]));
        Task.setResult(TaskResult.Succeeded, "");
    }

    static function main() {
        try {
            var versionSpec = Task.getInput("versionSpec", true);

            var installDir = null;

            installDir = Tool.findLocalTool("Haxe", versionSpec);

            if (installDir == null) {
                acquireHaxe(versionSpec)
                    .then(handleHaxeInstallPath)
                    .catchError(function(e:js.Error){
                        Task.setResult(TaskResult.Failed, e.message);
                    });
            } else {
                handleHaxeInstallPath(installDir);
            }
        } catch (e:js.Error) {
            Task.setResult(TaskResult.Failed, e.message);
        }
    }
}