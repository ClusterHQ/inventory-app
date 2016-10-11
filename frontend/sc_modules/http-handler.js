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

	// POST /vihicles
	expressApp.post('/vehicles', require('../controllers/vehicles.js').addVehicle)

	//(GET) A Dealership (by ID)
	expressApp.get('/dealerships/:name', require('../controllers/dealership.js').getDealership)

	//(GET) A Vehicle (by ID)
	expressApp.get('/vehicles/:id', require('../controllers/vehicles.js').getVehicle)

	//(DELETE) Remove vehicle
	expressApp.delete('/vehicles/:id', require('../controllers/vehicles.js').delVehicle)

	//(DELETE) Remove dealership
	expressApp.delete('/dealerships/:name', require('../controllers/dealership.js').delDealership)


	/* TODO, remove from list when complete */

	//(GET) Dealerships by attribute (name, address, phone)
	//(GET) Vehicles by attribute (make, model, year, vin)

};
