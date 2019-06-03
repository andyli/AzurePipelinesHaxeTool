package azure_pipelines_task_lib;

import haxe.extern.Rest;

@:jsRequire("azure-pipelines-task-lib/task", "TaskResult")
extern class TaskResult {
    static public var Succeeded:Int;
    static public var SucceededWithIssues:Int;
    static public var Failed:Int;
    static public var Cancelled:Int;
    static public var Skipped:Int;
}

@:jsRequire("azure-pipelines-task-lib/task")
extern class Task {
    static public function setStdStream(args:Rest<Dynamic>):Dynamic;
    static public function setErrStream(args:Rest<Dynamic>):Dynamic;
    static public function setResult(args:Rest<Dynamic>):Dynamic;
    static public function setResourcePath(args:Rest<Dynamic>):Dynamic;
    static public function loc(args:Rest<Dynamic>):Dynamic;
    static public function getVariable(args:Rest<Dynamic>):Dynamic;
    static public function assertAgent(args:Rest<Dynamic>):Dynamic;
    static public function getVariables(args:Rest<Dynamic>):Dynamic;
    static public function setVariable(name:String, val:String, ?secret:Bool):Void;
    static public function setSecret(args:Rest<Dynamic>):Dynamic;
    static public function getInput(args:Rest<Dynamic>):Dynamic;
    static public function getBoolInput(args:Rest<Dynamic>):Dynamic;
    static public function getDelimitedInput(args:Rest<Dynamic>):Dynamic;
    static public function filePathSupplied(args:Rest<Dynamic>):Dynamic;
    static public function getPathInput(args:Rest<Dynamic>):Dynamic;
    static public function getEndpointUrl(args:Rest<Dynamic>):Dynamic;
    static public function getEndpointDataParameter(args:Rest<Dynamic>):Dynamic;
    static public function getEndpointAuthorizationScheme(args:Rest<Dynamic>):Dynamic;
    static public function getEndpointAuthorizationParameter(args:Rest<Dynamic>):Dynamic;
    static public function getEndpointAuthorization(args:Rest<Dynamic>):Dynamic;
    static public function getSecureFileName(args:Rest<Dynamic>):Dynamic;
    static public function getSecureFileTicket(args:Rest<Dynamic>):Dynamic;
    static public function getTaskVariable(args:Rest<Dynamic>):Dynamic;
    static public function setTaskVariable(args:Rest<Dynamic>):Dynamic;
    static public function command(args:Rest<Dynamic>):Dynamic;
    static public function warning(args:Rest<Dynamic>):Dynamic;
    static public function error(args:Rest<Dynamic>):Dynamic;
    static public function debug(args:Rest<Dynamic>):Dynamic;
    static public function stats(args:Rest<Dynamic>):Dynamic;
    static public function exist(args:Rest<Dynamic>):Dynamic;
    static public function writeFile(args:Rest<Dynamic>):Dynamic;
    static public function osType(args:Rest<Dynamic>):Dynamic;
    static public function getPlatform(args:Rest<Dynamic>):Dynamic;
    static public function cwd(args:Rest<Dynamic>):Dynamic;
    static public function checkPath(args:Rest<Dynamic>):Dynamic;
    static public function cd(args:Rest<Dynamic>):Dynamic;
    static public function pushd(args:Rest<Dynamic>):Dynamic;
    static public function popd(args:Rest<Dynamic>):Dynamic;
    static public function mkdirP(args:Rest<Dynamic>):Dynamic;
    static public function resolve(args:Rest<Dynamic>):Dynamic;
    static public function which(args:Rest<Dynamic>):Dynamic;
    static public function ls(args:Rest<Dynamic>):Dynamic;
    static public function cp(args:Rest<Dynamic>):Dynamic;
    static public function mv(args:Rest<Dynamic>):Dynamic;
    static public function find(args:Rest<Dynamic>):Dynamic;
    static public function legacyFindFiles(args:Rest<Dynamic>):Dynamic;
    static public function rmRF(args:Rest<Dynamic>):Dynamic;
    static public function exec(args:Rest<Dynamic>):Dynamic;
    static public function execSync(args:Rest<Dynamic>):Dynamic;
    static public function tool(args:Rest<Dynamic>):Dynamic;
    static public function match(args:Rest<Dynamic>):Dynamic;
    static public function filter(args:Rest<Dynamic>):Dynamic;
    static public function findMatch(args:Rest<Dynamic>):Dynamic;
    static public function getHttpProxyConfiguration(args:Rest<Dynamic>):Dynamic;
    static public function getHttpCertConfiguration(args:Rest<Dynamic>):Dynamic;
    static public function TestPublisher(args:Rest<Dynamic>):Dynamic;
    static public function CodeCoveragePublisher(args:Rest<Dynamic>):Dynamic;
    static public function CodeCoverageEnabler(args:Rest<Dynamic>):Dynamic;
    static public function uploadFile(args:Rest<Dynamic>):Dynamic;
    static public function prependPath(args:Rest<Dynamic>):Dynamic;
    static public function uploadSummary(args:Rest<Dynamic>):Dynamic;
    static public function addAttachment(args:Rest<Dynamic>):Dynamic;
    static public function setEndpoint(args:Rest<Dynamic>):Dynamic;
    static public function setProgress(args:Rest<Dynamic>):Dynamic;
    static public function logDetail(args:Rest<Dynamic>):Dynamic;
    static public function logIssue(args:Rest<Dynamic>):Dynamic;
    static public function uploadArtifact(args:Rest<Dynamic>):Dynamic;
    static public function associateArtifact(args:Rest<Dynamic>):Dynamic;
    static public function uploadBuildLog(args:Rest<Dynamic>):Dynamic;
    static public function updateBuildNumber(args:Rest<Dynamic>):Dynamic;
    static public function addBuildTag(args:Rest<Dynamic>):Dynamic;
    static public function updateReleaseName(args:Rest<Dynamic>):Dynamic;
    static public function TaskCommand(args:Rest<Dynamic>):Dynamic;
    static public function commandFromString(args:Rest<Dynamic>):Dynamic;
    static public function ToolRunner(args:Rest<Dynamic>):Dynamic;
}