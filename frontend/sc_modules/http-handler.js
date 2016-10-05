db = require('../db/dbutils')
rdb = require('rethinkdb')

module.exports.attach = function (expressApp) {
	// Setup HTTP/REST API for Server Side.

	// Connect to RethinkDB
	dbconn = db.connect();

	// Simple GET /ping for testing HTTP
	expressApp.get('/ping',(req,res) => {
		console.log('recieved ping request')
		// send back "pong"
		res.send('pong\n')
	})

	// GET /dealerships (All Dealerships)
	expressApp.get('/dealerships', require('../controllers/dealership.js').getDealerships)

	// POST /dealerships 
	expressApp.post('/dealerships', require('../controllers/dealership.js').addDealership)

	// GET /vehicles (All Vehicles)
	expressApp.get('/vehicles', require('../controllers/vehicles.js').getVehicles)

	// POST /dealerships 
	expressApp.post('/vehicles', require('../controllers/vehicles.js').addVehicle)

	/* TODO, remove from list when complete */

	//(DELETE) Remove vehicles from Dealership(s)
	//(GET) A Dealership (by ID)
	//(GET) A Vehicle (by ID)
	//(GET) A Dealership by attribute (name, address, phone)
	//(GET) A Vehicle by attribute (make, model, year, vin)

};
