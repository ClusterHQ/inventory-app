/* Test HTTP API for Vehicles
   These tests are meant to run against a deployment of the app
   which means to run docker-compose up and then run the tests
   and then docker-compose stop/rm
*/

/* import libs for tests*/
r = require('rethinkdb');
var assert = require('assert');
var request = require('request');
var db = require('../db/dbutils');

var apihost = process.env.FRONTEND_HOST || 'localhost'
var apiport = process.env.FRONTEND_PORT || 8000;

const util = require('util');

describe('POST HTTPTests for Vehicles', function() {

  /*All tests here*/
  describe('Testing POST operations to /vehicles endpoint', function() {

    it('/vehicles POST should return HTTP 201 Created and return expected result from GET', function (done) {
      var dbConnect = db.connect();
      dbConnect.then(function(conn) {
          // Get a random DealerID
          r.table('Dealership').run(conn, function(err, cursor){
            cursor.toArray(function(err, results) {
              if (err) throw err;
              // Choose a random ID to add a vehicle to.
              // between 0 and results.length
              var dealerId = results[(Math.floor((Math.random() * results.length-1)))].id
              request({
                url: util.format('http://%s:%s/vehicles', apihost, apiport),
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json'
                },
                json: {
                  "dealership": dealerId,
                  "make": "Nissan",
                  "model": "frontier XL",
                  "vin" : "XABVPIWZNLQMFGXQS",
                  "year" : "2013",
                  "id" : "25e790cb-806e-4818-8485-b176d3934d55"
                }
              }, function (err, res, body) {
                if (err) throw (err);
                // Delete the vehicle that we created.
                if (res.statusCode == 201) {
                  // if POST went through, let's retreive it.
                  request({
                    url: util.format('http://%s:%s/vehicles/25e790cb-806e-4818-8485-b176d3934d55', apihost, apiport),
                    method: 'GET'
                  }, function (err, res, body) {
                    // A vehicle object to compare, e.g. what we expect
                    // the response to look like.
                    // JSON pars + stringify always does it alphabetically.
                    var vehicleObj = {
                      dealership: dealerId,
                      id : '25e790cb-806e-4818-8485-b176d3934d55',
                      make: 'Nissan',
                      model: 'frontier XL',
                      vin : 'XABVPIWZNLQMFGXQS',
                      year : '2013'
                    }
                    // Let us remove the Vehicle since we have it in memory
                    // in the top-level 'body'
                    request({
                      uri: util.format('http://%s:%s/vehicles/%s', apihost, apiport, '25e790cb-806e-4818-8485-b176d3934d55'),
                      method: "DELETE"}, function (error, response, body) {
                        if (!error && response.statusCode == 200) {
                          console.log("Deleted Vehicle for Cleanup")
                          console.log(body)
                          }
                        else{
                          console.log(error)
                          console.log(response.statusCode)
                          }
                      })
                    // Compare the top-level 'body', which should be the same as our vehicle object
                    assert.strictEqual(JSON.stringify(JSON.parse(body)[0]), JSON.stringify(vehicleObj));
                    done();
                  })
                }else{
                  assert.fail(res.statusCode, 201, "POST before GET failed.");
                  done();
                }
              })
            });
          });
        }).error(function(error) {
          throw (error);
        });
    })

  });
  /*end tests*/
});