db = require('../db/dbutils')
rdb = require('rethinkdb')

module.exports.addDealership = function (req, res) {
	console.log('Creating a new dealership');
	console.log(req.body);
	console.log('Dealership name is ' + req.body.name);
	dbconn = db.connect();
	dbconn.then(function (conn) {
		rdb.table('Dealership').insert(req.body).run(conn, function(err, results){
			console.log(results);
			conn.close();
		});
	});
	res.send({message: 'hello'})
}

