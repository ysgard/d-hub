/**
 * d-hub, a githook web app.
 *
 * Author: Jan (ysgard) Van Uytven, ysgard@gmail.com
 *
 */

module ysgard.dhub;

import std.json;
import vibe.d;

shared static this()
{
	auto settings = new HTTPServerSettings;
	settings.port = 9003;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, &hook);
}

void hook(HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody("Event received!");
}
