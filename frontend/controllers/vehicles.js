db = require('../db/dbutils')
rdb = require('rethinkdb')

module.exports.addVehicle = function (req, res) {
	console.log('Creating a new vehicle');
	console.log(req.body);
	if (req.body.vin == undefined) {
		var status = 400;
		res.status(status).send({ status: 'Bad request for Create' })
	}
	else if (req.body.make == undefined) {
		var status = 400;
		res.status(status).send({ status: 'Bad request for Create' })
	}
	else if (req.body.model == undefined) {
		var status = 400;
		res.status(status).send({ status: 'Bad request for Create' })
	}
	else if (req.body.year == undefined) {
		var status = 400;
		res.status(status).send({ status: 'Bad request for Create' })
	}else{
		dbconn = db.connect();
		dbconn.then(function (conn) {
			rdb.table('Vehicle').insert(req.body).run(conn, function(err, results){
				console.log(results);
				conn.close();
				if (err) {
					var status = 500;
					res.status(status).send({ status: 'Error during Create' })
				}else {
					var status = 201;
					res.status(status).send({ status: 'Create Successful' })
				}
			});
		});
	}
}

module.exports.getVehicles = function (req, res) {
	console.log('recieved vehicles request')
	dbconn = db.connect();
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

module.exports.getVehicle = function (req, res) {
	console.log('recieved /vehicles/:id request')
	dbconn = db.connect();
	dbconn.then(function(conn) {
		rdb.table('Vehicle').filter({id: req.params.id}).run(conn, function(err, cursor) {
      		if (err) throw err;
      		cursor.toArray(function(err, result) {
          		if (err) throw err;
          		console.log("Sending back Vehicle results");
          		res.send(JSON.stringify(result, null, 2));
        	});
    	});
  	})
}

module.exports.delVehicle = function (req, res) {
	console.log('recieved DELETE /vehicles/:id request')
	dbconn = db.connect();
	dbconn.then(function(conn) {
		rdb.table('Vehicle').filter({id: req.params.id}).delete().run(conn, function(err, cursor) {
      		if (err) throw err;
			conn.close();
  		});	
	});
	var status = 200;
  	res.status(status).send({ status: 'Delete Successful' })
}

module.exports.getVehiclesSize = function (req, res) {
  console.log('Received GET /vehicles/size request')
  dbconn = db.connect();
  dbconn.then(function(conn) {
    rdb.table('Vehicle').count().run(conn, function(err, results){
      conn.close();
      if (err) {
      	var status = 500;
        res.status(status).send({ status: 'Could not get size of Vehicles: ' + err })
      }else{
        var status = 200;
        res.status(status).send({ status: 'Size: ' + results })
      }
    });
  });
}
