/**
 * d-hub, a githook web app.
 *
 * Author: Jan (ysgard) Van Uytven, ysgard@gmail.com
 *
 */

module ysgard.dhub;

import core.stdc.stdlib;
import std.file;
import std.process;
import std.string;
import vibe.d;

enum Action { shell, rabbitmq }

struct Hook {
	string branch;
	Action action;
	string cmd;
}

struct Config {
	string configFile;
	string logFile;
	string address;
	short port;
	Hook[string] hooks;
}

Config config;

// Check to make sure the configuration file exists, then read it.
void readConfig(string configFile) {

	if (exists(configFile)) {
		// Load the config
		auto jsonString = to!string(read(configFile));

		// Parse the config file into the config struct
		auto c = parseJsonString(jsonString);
		if (c["port"].type != Json.undefined) config.port = c["port"].get!short();
		if (c["logfile"].type != Json.undefined) config.logFile = c["logfile"].get!string();
		if (c["address"].type != Json.undefined) config.address = c["address"].get!string();
		int hooksProcessed = 0;
		foreach(size_t index, Json hook; c["hooks"]) {
			Action hookAction;
			switch(hook["action"].get!string()) {
			case "shell":
				hookAction = Action.shell;
				break;
			case "rabbitmq":
				hookAction = Action.rabbitmq;
				break;
			default:
				logFatal("Unknown action %s!", hook["action"].get!string());
			}
			config.hooks[hook["repo"].get!string()] = Hook(hook["branch"].get!string(), hookAction,
																										 hook["command"].get!string());
		}
		
		// Override port and logFile if the user passed those as command-line options
		readOption!string("address|i", &config.address, "The interface IP address to listen on");
		readOption!short("port|p", &config.port, "The port on which d-hub will listen for github events.");
		readOption!string("log|l", &config.logFile, "The logfile used by d-hub.  Default is ./d-hub.log");
	 
	} else {
		logFatal("Cannot read configuration file: %s does not exist!", configFile);
		exit(1);
	}
}


void hook(HTTPServerRequest req, HTTPServerResponse res) {
	// Check to make sure we have the required fields
	logInfo("Router received event, processing...");
	enforceHTTP("repo" in req.params, HTTPStatus.badRequest, "Missing repo field.");
	enforceHTTP("branch" in req.params, HTTPStatus.badRequest, "Missing branch field.");
	res.writeBody(format("Event received! %s/%s\n\n%s", req.params["repo"], req.params["branch"], req.toString()));
	if(req.params["repo"] in config.hooks) {
		// Loaded hook, call the command
		auto cmd = config.hooks[req.params["repo"]].cmd;
		switch (config.hooks[req.params["repo"]].action) {
		default:
			// log strange action and exit
			logWarn("Action %d for %s/%s not recognized, skipping...", req.params["repo"], req.params["branch"]);
			break;
		case Action.shell:
			logInfo("Spawning shell for command:\n%s", cmd);
			auto pid = spawnShell(cmd);
			auto exitCode = wait(pid);
			logInfo("Shell command completed, status=%d", exitCode);
			break;
		case Action.rabbitmq:
			logInfo("Rabbitmq processing not handled at this time!");
			break;
		}
	}
}

void dumpConfig() {
	logInfo("logFile : %s", config.logFile);
	logInfo("address : %s", config.address);
	logInfo("port : %d", config.port);
	foreach (repo, hook; config.hooks) {
		logInfo("---");
		logInfo("repo : %s", repo);
		logInfo("  branch : %s", hook.branch);
		logInfo("  action : %d", hook.action);
		logInfo("  command : %s", hook.cmd);
	}
}


shared static this() {
	
	// Check to make sure we're passed a configuration file, and that it exists.
	string configFile = readRequiredOption!string("config|c", "The configuration file used by d-hub");
	readConfig(configFile);	
	//dumpConfig();
	// Tell Vibe to log to the specified logfile
	setLogFile(config.logFile);

	// Create new routers to handle the hooks
	auto router = new URLRouter;
	router.post("/:repo/:branch", &hook);
	

	// Start the server and listen
	auto settings = new HTTPServerSettings;
	settings.port = config.port;
	settings.bindAddresses = [config.address];
	listenHTTP(settings, router);
}
