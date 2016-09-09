/* Test HTTP API 
   These tests are meant to run against a deployment of the app
   which means to run docker-compose up and then run the tests
   and then docker-compose stop/rm
*/

/* import libs for tests*/
r = require('rethinkdb');
var assert = require('assert');
var request = require('request');

// Database host and port.
// Should these vars be centralized?
var host = process.env.DATABASE_HOST || '127.0.0.1';
var port = process.env.DATABASE_PORT || 28015;
var conn = null

// Setup the connection
r.connect({host: host, port: port}, function(err, connection) {
      if (err) throw err;
      console.log("Connected to RethinkDB");
        conn = connection
})

describe('HTTPTests', function() {

  after(function() {
    //close connection after all tests
    conn.close()
  });

  /*All tests here*/
  describe('Testing /ping endpoint', function() {

    it('/ping should return "200"', function(done) {
      request.get('http://localhost:8000/ping', function (err, res, body){
        if (err) throw (err);
        assert.strictEqual(res.statusCode, 200);
        done();
      });
    });

    it('/ping should return text/html; charset=utf-8', function(done) {
      request.get('http://localhost:8000/ping', function (err, res, body){
        if (err) throw (err);
        assert.equal(res.headers['content-type'], "text/html; charset=utf-8");
        done();
      });
    });

    it('/ping should return "pong"', function(done) {
      request.get('http://localhost:8000/ping', function (err, res, body){
        if (err) throw (err);
        assert.equal(res.body, 'pong\n');
        done();
      });
  });

  describe('Testing /dealerships endpoint', function() {

    it('/dealerships should return "200"', function(done) {
      request.get('http://localhost:8000/dealerships', function (err, res, body){
        if (err) throw (err);
        assert.strictEqual(res.statusCode, 200);
        done();
      });
    });

    it('/dealerships should return the right amount of dealers in the db', function(done) {
      request.get('http://localhost:8000/dealerships', function (err, res, body){
        if (err) throw (err);
        var dealers = JSON.parse(res.text);
        r.table('Dealership').count().run(conn, function(err, results){
          assert.strictEqual(dealers.length, results, "same results from DB and HTTP response")
          done();
        }); 
      });
    });

  });

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
        var vehicles = JSON.parse(res.text);
        r.table('Vehicle').count().run(conn, function(err, results){
          assert.strictEqual(vehicles.length, results, "same results from DB and HTTP response")
          done();
        }); 
      });
    });

  });

  /*end tests*/
});
