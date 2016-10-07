/* Test HTTP API for Dealers
   These tests are meant to run against a deployment of the app
   which means to run docker-compose up and then run the tests
   and then docker-compose stop/rm
*/

/* import libs for tests*/
r = require('rethinkdb');
var assert = require('assert');
var request = require('request');

var apihost = process.env.FRONTEND_HOST || 'localhost'
var apiport = process.env.FRONTEND_PORT || 8000;

const util = require('util');

describe('POST HTTPTests for Dealerships', function() {

  /*All tests here*/
  describe('Testing POST operations to /dealerships endpoint', function() {

    it('/dealerships POST should return HTTP 201 Created', function (done) {
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
        request({
            uri: util.format('http://%s:%s/dealerships/%s', apihost, apiport, 'New%20Dealer'),
            method: "DELETE"}, function (error, response, body) {
            if (!error && response.statusCode == 200) {
              console.log("Deleted Dealer for Cleanup")
              console.log(body)
              }
            else{
              console.log(error)
              console.log(response.statusCode)
            }
        })
        assert.strictEqual(res.statusCode, 201)
        done();
      })
    })

  });
  /*end tests*/
});