db = require('../db/dbutils')
rdb = require('rethinkdb')

module.exports.addVehicle = function (req, res) {
	console.log('Creating a new vehicle');
	console.log(req.body);
	console.log('Vehicle vin is ' + req.body.vin);
	console.log('Vehicle make is ' + req.body.make);
	console.log('Vehicle model is ' + req.body.model);
	dbconn = db.connect();
	dbconn.then(function (conn) {
		rdb.table('Vehicle').insert(req.body).run(conn, function(err, results){
			console.log(results);
			conn.close();
		});
	});
	var status = 201;
	res.status(status).send({ status: 'Successful' })
}

module.exports.getVehicles = function (req, res) {
	console.log('recieved vehicles request')
	dbconn.then(function(conn) { 
		rdb.table('Vehicle').run(conn, function(err, cursor) {
			if (err) throw err;
			cursor.toArray(function(err, result) {
				if (err) throw err;
				console.log("Sending back Vehicle results");
				res.send(JSON.stringify(result, null, 2));
				});
		});
	})
}