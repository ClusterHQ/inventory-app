/* import libs for tests*/
r = require('rethinkdb');

// Database host and port.
// Should these vars be centralized?
var host = process.env.DATABASE_HOST || '127.0.0.1';
var port = process.env.DATABASE_PORT || 28015;

// Setup the connection
exports.connect = function connect() {
	return r.connect({host: host, port: port}) 
}

