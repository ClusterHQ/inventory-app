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

    it('/dealerships POST and subsequent GET object should match', function (done) {
      request({
        url: util.format('http://%s:%s/dealerships', apihost, apiport),
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        json: {
          name: 'New dealer',
          phone: '555-999-1122',
          addr: '123 Street, City, State, ######-####',
          id: '13674ddc-3196-4a0c-9996-ed6503ff4d49'
        }
      }, function (err, res, body) {
        if (err) throw (err);
        if (res.statusCode == 201) {
          request({
            url: util.format('http://%s:%s/dealerships/New%20dealer', apihost, apiport),
            method: 'GET'
          }, function (err, res, body) {
            // JSON pars + stringify always does it alphabetically.
            var dealerObj = {
              addr: '123 Street, City, State, ######-####',
              id: '13674ddc-3196-4a0c-9996-ed6503ff4d49',
              name: 'New dealer',
              phone: '555-999-1122'
            }
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
            assert.strictEqual(JSON.stringify(JSON.parse(body)[0]), JSON.stringify(dealerObj));
            done();
          })
        }else{
          assert.fail(res.statusCode, 201, "POST before GET failed.");
          done();
        }
      })
    })

  });
  /*end tests*/
});