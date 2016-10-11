/* Test HTTP API for Dealers
   These tests are meant to run against a deployment of the app
   which means to run docker-compose up and then run the tests
   and then docker-compose stop/rm
*/

/* import libs for tests*/
r = require('rethinkdb');
var assert = require('assert');
var request = require('request');
var db = require('../db/dbutils');
var dbConnect = db.connect();

var apihost = process.env.FRONTEND_HOST || 'localhost'
var apiport = process.env.FRONTEND_PORT || 8000;

const util = require('util');

describe('HTTPTests for Dealerships', function() {

  /*All tests here*/
  describe('Testing /dealerships endpoint', function() {

    it('/dealerships should return "200"', function(done) {
      request.get(util.format('http://%s:%s/dealerships', apihost, apiport), function (err, res, body){
        if (err) throw (err);
        assert.strictEqual(res.statusCode, 200);
        done();
      });
    });

    it('/dealerships should return the right amount of dealers in the db', function(done) {
      request.get(util.format('http://%s:%s/dealerships', apihost, apiport), function (err, res, body){
        if (err) throw (err);
        var dealers = JSON.parse(res.body);
        dbConnect.then(function(conn) {
          r.table('Dealership').count().run(conn, function(err, results){
            assert.strictEqual(dealers.length, results, "same results from DB and HTTP response");
            conn.close();
            done();
          });
        }).error(function(error) {
          throw (error);
        });
      });
    });

    it('/dealerships POST should return HTTP 201 Created', function () {
      request({
        url: util.format('http://%s:%s/dealerships', apihost, apiport),
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        json: {
          name: 'New dealer',
          phone: '555-999-1122',
          addr: '123 Street, City, State, ######-####'
        }
    }, function (err, res, body) {
        if (err) throw (err);
        assert.strictEqual(res.statusCode, 201)
      })
    })

  });
  /*end tests*/
});
