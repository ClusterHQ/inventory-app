/* Test HTTP API for Ping
   These tests are meant to run against a deployment of the app
   which means to run docker-compose up and then run the tests
   and then docker-compose stop/rm
*/

/* import libs for tests*/
var assert = require('assert');
var request = require('request');

var apihost = process.env.FRONTEND_HOST || 'localhost'
var apiport = process.env.FRONTEND_PORT || 8000;

describe('HTTPTests for Ping', function() {

  /*All tests here*/
  describe('Testing /ping endpoint', function() {

    it('/ping should return "200"', function(done) {
      request.get('http://' + apihost + ':'+ apiport +'/ping', function (err, res, body){
        if (err) throw (err);
        assert.strictEqual(res.statusCode, 200);
        done();
      });
    });

    it('/ping should return text/html; charset=utf-8', function(done) {
      request.get('http://' + apihost + ':'+ apiport +'/ping', function (err, res, body){
        if (err) throw (err);
        assert.equal(res.headers['content-type'], "text/html; charset=utf-8");
        done();
      });
    });

    it('/ping should return "pong"', function(done) {
      request.get('http://' + apihost + ':'+ apiport +'/ping', function (err, res, body){
        if (err) throw (err);
        assert.equal(res.body, 'pong\n');
        done();
      });
    });

  });
  /*end tests*/
});
