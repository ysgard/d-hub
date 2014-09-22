# D-Hub

A simple web app to catch GitHub webhook notifications and perform
actions.  Loosely based on [adjust/gohub](https://github.com/adjust/gohub).

## Usage

`./d-hub --config d-hub.json`

Where `d-hub.json` is a file containing the following configurables
and list of hooks:

```
{
	"port": 9003,
	"logfile": "./d-hub.log",
	"hooks: [
		{
			"repo": "my_repo",
			"branch": "master",
			"action": "shell",
			"command": "/opt/d-hub/scripts/update_my_repo.sh"
		},
		{
		...etc...
		}
   	]
}
```
			
	
*port* is the port d-hub will bind to.
*logfile* messages will be logged to here.
*hooks* This array takes a series of hook specifications.  Each hook
*represents a distinct event sent by github.
For example, the hook:
```
{
	"repo": "mywebsite.com",
	"branch": "deploy",
	"action": "shell",
	"command": "ruby /var/www/scripts/update_mywebsite.rb"
}
```
Would be called when you specify a GitHub webhook with the payload
`http://<hostname>:9003/mywebsite.com/deploy` and would run the script
*`/var/www/scripts/update_mywebsite.rb` by spawning a shell and
*invoking ruby.

## Compiling

* Make sure you have a [D compiler](http://dlang.org/)  and [dub](http://code.dlang.org/) installed.
* Clone the repository

`git clone https://github.com/ysgard/d-hub.git`

* Build the project

`cd d-hub`
`dub`

## License

This Software is licensed under the MIT License.

Copyright (c) 2014 Jan Van Uytven

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
