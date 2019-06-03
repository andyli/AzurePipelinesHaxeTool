import azure_pipelines_task_lib.Task;
import azure_pipelines_tool_lib.Tool;
import js.Promise;
import js.node.*;
import haxe.io.*;
using StringTools;

class Main {
    static var nekoVersion(default, never):String = "2.2.0";
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

    static function nekoUrl(version:String):String {
        var file = switch (platform) {
            case "win32":
                'neko-${version}-win.zip';
            case "darwin":
                'neko-${version}-osx64.tar.gz';
            case "linux":
                'neko-${version}-linux64.tar.gz';
            case _:
                throw "unsupported platform: " + platform;
        }
        return 'https://github.com/HaxeFoundation/neko/releases/download/v${version.replace(".", "-")}/${file}';
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

    static function acquireNeko(version:String):Promise<String> {
        var url = nekoUrl(version);
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
                return Tool.cacheDir(subDir, "neko", version);
            });
    }

    static function handleHaxeInstallPath(path:String):Null<Void> {
        Tool.prependPath(path);
        Task.setVariable("HAXE_STD_PATH", Path.join([path, "std"]));
        return null;
    }

    static function handleNekoInstallPath(path:String):Null<Void> {
        Tool.prependPath(path);
        Task.setVariable("NEKOPATH", path);
        return null;
    }

    static function main() {
        try {
            var versionSpec = Task.getInput("versionSpec", true);

            var nekoInstallDir:Promise<String> = switch (Tool.findLocalTool("neko", nekoVersion)) {
                case null:
                    acquireNeko(nekoVersion);
                case p:
                    Promise.resolve(p);
            };
            var haxeInstallDir:Promise<String> = switch (Tool.findLocalTool("haxe", versionSpec)) {
                case null:
                    acquireHaxe(versionSpec);
                case p:
                    Promise.resolve(p);
            };

            Promise.all([
                nekoInstallDir.then(handleNekoInstallPath),
                haxeInstallDir.then(handleHaxeInstallPath),
            ])
                .then(function(v) {
                    Task.setResult(TaskResult.Succeeded, "");
                })
                .catchError(function(e:js.Error){
                    Task.setResult(TaskResult.Failed, e.message);
                });
        } catch (e:js.Error) {
            Task.setResult(TaskResult.Failed, e.message);
        }
    }
}