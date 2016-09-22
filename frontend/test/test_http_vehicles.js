/* Test HTTP API for Vehicles
   These tests are meant to run against a deployment of the app
   which means to run docker-compose up and then run the tests
   and then docker-compose stop/rm
*/

/* import libs for tests*/
r = require('rethinkdb');
var assert = require('assert');
var request = require('request');
var db = require('./dbutils')
var dbConnect = db.connect();

describe('HTTPTests for Vehicles', function() {

  /*All tests here*/
  describe('Testing /vehicles endpoint', function() {

    it('/vehicles should return "200"', function(done) {
      request.get('http://localhost:8000/vehicles', function (err, res, body){
        if (err) throw (err);
        assert.strictEqual(res.statusCode, 200);
        done();
      });
    });

    it('/vehicles should return the right amount of vehicles in the db', function(done) {
      request.get('http://localhost:8000/vehicles', function (err, res, body){
        if (err) throw (err);
        var vehicles = JSON.parse(res.body);
        dbConnect.then(function(conn) {
          r.table('Vehicle').count().run(conn, function(err, results){
            assert.strictEqual(vehicles.length, results, "same results from DB and HTTP response")
            done();
          }); 
        }).error(function(error) {
          throw (error);
        });
      });
    });

  });
  /*end tests*/
});
