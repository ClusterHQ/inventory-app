db = require('../db/dbutils')
rdb = require('rethinkdb')

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