"use strict";
/* Test HTTP API 
   These tests are meant to run against a deployment of the app
   which means to run docker-compose up and then run the tests
   and then docker-compose stop/rm
*/

/* import libs for tests*/
var assert = require('assert');
var chai = require('chai')
  , chaiHttp = require('chai-http');

/* Setup needed test functions from chai*/
chai.use(chaiHttp);
var expect = chai.expect;

describe('HTTPTests', function() {

  /*All tests here*/
  describe('Testing /ping endpoint', function() {

    it('/ping should return "200"', function(done) {
      chai.request('http://localhost:8000')
      .get('/ping')
      .end(function(err, res) {
        expect(res).to.have.status(200);
        done();  
      });
    });

    it('/ping should return text/html; charset=utf-8', function(done) {
      chai.request('http://localhost:8000')
      .get('/ping')
      .end(function(err, res) {
        expect(res).to.be.html;
        done();  
      });
    });

    it('/ping should return "pong"', function(done) {
      chai.request('http://localhost:8000')
      .get('/ping')
      .end(function(err, res) {
        expect(res.text).to.equal('pong\n');
        done();  
      });
    });
  });

  describe('Testing /dealerships endpoint', function() {

    it('/dealerships should return "200"', function(done) {
      chai.request('http://localhost:8000')
      .get('/dealerships')
      .end(function(err, res) {
        expect(res).to.have.status(200);
        done();  
      });
    });

  });

  describe('Testing /vehicles endpoint', function() {

    it('/vehicles should return "200"', function(done) {
      chai.request('http://localhost:8000')
      .get('/vehicles')
      .end(function(err, res) {
        expect(res).to.have.status(200);
        done();  
      });
    });

  });
  /*end tests*/
});
