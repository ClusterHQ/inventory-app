db = require('../db/dbutils')
rdb = require('rethinkdb')

module.exports.addDealership = function (req, res) {
	console.log('Creating a new dealership');
	console.log(req.body);
	console.log('Dealership name is ' + req.body.name);
	if (req.body.addr == undefined) {
		var status = 400;
		res.status(status).send({ status: 'Bad request for Create' })
	}
	else if (req.body.name == undefined) {
		var status = 400;
		res.status(status).send({ status: 'Bad request for Create' })
	}
	else if (req.body.phone == undefined) {
		var status = 400;
		res.status(status).send({ status: 'Bad request for Create' })
	}else{
		dbconn = db.connect();
		dbconn.then(function (conn) {
			rdb.table('Dealership').insert(req.body).run(conn, function(err, results){
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

module.exports.getDealerships = function (req, res) {
  console.log('Received GET /dealerships request')
  dbconn = db.connect();
  dbconn.then(function(conn) {
    rdb.table('Dealership').run(conn, function(err, cursor) {
      if (err) throw err;
      cursor.toArray(function(err, result) {
          if (err) throw err;
          console.log("Sending back Dealership results");
          res.send(JSON.stringify(result, null, 2));
        });
    });
  })
}

module.exports.getDealership = function (req, res) {
  console.log('Received GET /dealerships/:name request')
  dbconn = db.connect();
  dbconn.then(function(conn) {
    rdb.table('Dealership').filter({name: req.params.name}).run(conn, function(err, cursor) {
      if (err) throw err;
      cursor.toArray(function(err, result) {
          if (err) throw err;
          console.log("Sending back Dealership results");
          res.send(JSON.stringify(result, null, 2));
        });
    });
  })
}

module.exports.delDealership = function (req, res) {
  console.log('Received DELETE /dealerships/:name request')
  dbconn = db.connect();
  dbconn.then(function(conn) {
    rdb.table('Dealership').filter({name: req.params.name}).delete().run(conn, function(err, cursor) {
    	if (err) throw err;
		conn.close();
    });
  });
  var status = 200;
  res.status(status).send({ status: 'Delete Successful' })
}
