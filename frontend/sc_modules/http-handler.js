r = require('rethinkdb');

module.exports.attach = function (expressApp) {
	// Setup HTTP/REST API for Server Side.

	// Should these vars be centralized?
	var host = process.env.DATABASE_HOST || '127.0.0.1';
	var port = process.env.DATABASE_PORT || 28015;

	var conn = null;
	r.connect({host: host, port: port}, function(err, connection) {
    		if (err) throw err;
    		console.log("Connected to RethinkDB");
    	   	conn = connection;
	})
	

	// Simple GET /ping for testing HTTP
	expressApp.get('/ping',(req,res) => {
		console.log('recieved ping request')
		// send back "pong"
		res.send('pong\n')
	})

	// GET /dealerships (All Dealerships)
	expressApp.get('/dealerships',(req,res) => {
		console.log('recieved dealerships request')
		r.table('Dealership').run(conn, function(err, cursor) {
    		if (err) throw err;
    		cursor.toArray(function(err, result) {
        		if (err) throw err;
        		console.log("Sending back Dealership results");
        		res.send(JSON.stringify(result, null, 2));
    			});
		});
	})

	// GET /vehicles (All Vehicles)
	expressApp.get('/vehicles',(req,res) => {
		console.log('recieved vehicles request')
		r.table('Vehicle').run(conn, function(err, cursor) {
    		if (err) throw err;
    		cursor.toArray(function(err, result) {
        		if (err) throw err;
        		console.log("Sending back Vehicle results");
        		res.send(JSON.stringify(result, null, 2));
    			});
		});
	})

	/* TODO, remove from list when complete */

	//(POST) Dealership(s)
	//(POST) vehicles to Dealership(s)
	//(DELETE) Remove vehicles from Dealership(s)
	//(GET) A Dealership (by ID)
	//(GET) A Vehicle (by ID)
	//(GET) A Dealership by attribute (name, address, phone)
	//(GET) A Vehicle by attribute (make, model, year, vin)

};
