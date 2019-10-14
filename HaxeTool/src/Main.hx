import azure_pipelines_task_lib.Task;
import azure_pipelines_tool_lib.Tool;
import js.Promise;
import js.node.*;
import haxe.io.*;
import sys.*;
import Fetch.*;
using StringTools;
using Lambda;

class Main {
    static var nekoVersion(default, never):String = "2.2.0";
    static var platform(default, never):String = Os.platform();

    static function haxeUrl(version:String):String {
        switch (version) {
            case "development":
                var file = switch (platform) {
                    case "win32":
                        "windows64/haxe_latest.zip";
                    case "darwin":
                        "mac/haxe_latest.tar.gz";
                    case "linux":
                        "linux64/haxe_latest.tar.gz";
                    case _:
                        throw "unsupported platform: " + platform;
                }
                return 'https://build.haxe.org/builds/haxe/${file}';
            case _:
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
        };
    }

    static function nekoUrl(version:String, arch:Int):String {
        var file = switch (platform) {
            case "win32":
                'neko-${version}-win${arch == 64 ? "64" : ""}.zip';
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

    static function queryLatestHaxeVersionMatch(versionSpec:String):Promise<String> {
        return fetch("https://haxe.org/website-content/downloads/versions.json")
            .then(function(res) return res.json())
            .then(function(json:{
                current:String,
                versions:Array<{
                    date:String,
                    version:String,
                    tag:String,
                }>,
            }) {
                return Tool.evaluateVersions(json.versions.map(function(o) return o.version), versionSpec);
            });
    }

    static function acquireHaxe(version:String, cache:Bool):Promise<String> {
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
                return if (cache) {
                    Tool.cacheDir(subDir, "haxe", version);
                } else {
                    Promise.resolve(subDir);
                }
            });
    }

    static function acquireNeko(version:String, arch:Int):Promise<String> {
        var url = nekoUrl(version, arch);
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
                return Tool.cacheDir(subDir, "neko", version, arch == 32 ? "x86" : "x64");
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

        switch (platform) {
            case "darwin", "linux":
                Task.execSync("sudo", ["mkdir", "-p", "/usr/local/lib/"]);
                FileSystem.readDirectory(path)
                    .filter(function(item) return item.startsWith("libneko."))
                    .iter(function(itm){
                        Task.execSync("sudo", ["ln", "-s", Path.join([path, itm]), "/usr/local/lib/"]);
                    });
                Task.execSync("sudo", ["mkdir", "-p", "/usr/local/lib/neko/"]);
                FileSystem.readDirectory(path)
                    .filter(function(item) return item.endsWith(".ndll"))
                    .iter(function(itm){
                        Task.execSync("sudo", ["ln", "-s", Path.join([path, itm]), "/usr/local/lib/neko/"]);
                    });
            case _:
                //pass
        }

        switch (platform) {
            case "linux":
                Task.execSync("sudo", ["ldconfig"]);
            case _:
                //pass
        }
        return null;
    }

    static function main() {
        try {
            var versionSpec = Task.getInput("versionSpec", true);

            var haxeVersion:Promise<String> = switch (versionSpec) {
                case "development":
                    Promise.resolve("development");
                case v if (Tool.isExplicitVersion(v)):
                    Promise.resolve(v);
                case _:
                    queryLatestHaxeVersionMatch(versionSpec);
            }

            var nekoInstallDir:Promise<String> =
                haxeVersion.then(function(haxeVersion:String) {
                    var nekoArch = switch ([platform, haxeVersion]) {
                        case ["win32", "development"]: 64;
                        case ["win32", v] if (Std.parseInt(v.split(".")[0]) >= 4): 64;
                        case ["win32", _]: 32;
                        case _: 64;
                    }
                    return switch (Tool.findLocalTool("neko", nekoVersion, nekoArch == 32 ? "x86" : "x64")) {
                        case null:
                            acquireNeko(nekoVersion, nekoArch);
                        case p:
                            p;
                    };
                });

            var haxeInstallDir:Promise<String> = haxeVersion.then(function(haxeVersion:String) {
                return switch (haxeVersion) {
                    case "development":
                        acquireHaxe(haxeVersion, false);
                    case _:
                        switch (Tool.findLocalTool("haxe", haxeVersion)) {
                            case null:
                                acquireHaxe(haxeVersion, true);
                            case p:
                                Promise.resolve(p);
                        };
                }
            });

            Promise.all([
                nekoInstallDir.then(handleNekoInstallPath),
                haxeInstallDir.then(handleHaxeInstallPath),
            ])
                .then(function(v) {
                    var haxelibConfig = Path.join([Task.getVariable("Pipeline.Workspace"), "haxelib"]);
                    Task.mkdirP(haxelibConfig);
                    Task.execSync("haxelib", ["setup", haxelibConfig]);
                })
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