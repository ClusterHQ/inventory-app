/* Test HTTP API for Dealers
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

describe('Test Dealer Phone Numbers for Dealerships', function() {

  /*All tests here*/
  describe('Testing dealership phone numbers', function() {

    it('dealership phone numbers should be 012-345-6789', function(done) {
        var dbConnect = db.connect();
        dbConnect.then(function(conn) {
          r.table('Dealership').run(conn, function(err, results){
            results.each(function(err, dealer) {
        		if (err) throw err;
        		var phoneStr = dealer.phone;
				var patt = new RegExp("[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]");
				// test that all phone numbers match 555-555-5555
				var res = patt.test(phoneStr);
				// Assert that this is true.
        		assert(res, util.format('Failed on dealer Dealer:%s Phone:%s', dealer.name, dealer.phone));
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
