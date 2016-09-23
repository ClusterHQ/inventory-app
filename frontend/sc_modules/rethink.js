rethink = require('rethinkdb');

var host = process.env.DATABASE_HOST || '127.0.0.1';
var port = process.env.DATABASE_PORT || 28015;

module.exports.connect = function connect() {
	return rethink.connect({host: host, port: port})
}