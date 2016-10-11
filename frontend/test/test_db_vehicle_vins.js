/* Test DB API for Vehicle Vins
	 These tests are meant to run against a deployment of the app
	 which means to run docker-compose up and then run the tests
	 and then docker-compose stop/rm
*/

/* import libs for tests*/
r = require('rethinkdb');
var assert = require('assert');
var db = require('../db/dbutils');

var apihost = process.env.FRONTEND_HOST || 'localhost'
var apiport = process.env.FRONTEND_PORT || 8000;

const util = require('util');

describe('Test Vehicle VIN numbers', function() {

	/*All tests here*/
	describe('Testing vehicle VINs', function() {

		it('VIN should have only A-Z, 0-9 characters, 17 chars', function(done) {
				var dbConnect = db.connect();
				dbConnect.then(function(conn) {
					r.table('Vehicle').run(conn, function(err, results){
						results.each(function(err, vehicle) {
						if (err) throw err;
						var vinStr = vehicle.vin;
						// VIN should have only A-Z, 0-9 characters, but not I, O, or Q
						// Last 6 characters of VIN should be a number
						// VIN should be 17 characters long
						// (*** We are not using REAL vins, so just match against
						// the fake one of cap # and Letters ***)
						var patt = new RegExp("^[A-Z0-9]{17}");
						var res = patt.test(vinStr);
						// Assert that this is true.
						assert(res, util.format('Failed on vehicle vin :%s', vehicle.vin));
				}, function() {
						conn.close();
						done();
						});
					});
				}).error(function(error) {
					throw (error);
				});
		});

	});
	/*end tests*/
});
