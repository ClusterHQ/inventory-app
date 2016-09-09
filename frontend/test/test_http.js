"use strict";
/* Test HTTP API 
   These tests are meant to run against a deployment of the app
   which means to run docker-compose up and then run the tests
   and then docker-compose stop/rm
*/

/* import libs for tests*/
var assert = require('assert');
var request = require('request');
var chai = require('chai')
  , chaiHttp = require('chai-http');

/* Setup needed test functions from chai*/
chai.use(chaiHttp);
var expect = chai.expect;

describe('HTTPTests', function() {

  /*All tests here*/
  describe('GET /dealers', function() {

  	it('should return "200"', function(done) {
      request.get('http://localhost:8000/dealers', function (err, res, body){
        expect(res.statusCode).to.equal(200);
        done();
      });
    });

  	it('should return text/html; charset=utf-8', function(done) {
      request.get('http://localhost:8000/dealers', function (err, res, body){
        expect(res).to.be.html;
        done();
      });
    });

  	it('should return "Sending Dealers"', function(done) {
      request.get('http://localhost:8000/dealers', function (err, res, body){
        expect(res.body).to.equal('Sending Dealers\n');
        done();
      });
    });
  });
  /*end tests*/
});
