"use strict";
/* Test HTTP API */

/* NOTE ABOUT TESTING
   These tests are meant to run against a deployment of the app
   which means to run docker-compose up and then run the tests
   and then docker-compose stop/rm
*/

/* import libs for tests*/
var assert = require('assert');
var chai = require('chai')
  , chaiHttp = require('chai-http');

/* Import the frontend server*/
//var sc = require('../server');
//var server;
//See NOTE ABOUT TESTING AT TOP OF PAGE^^ 

/* Setup needed test functions from chai*/
chai.use(chaiHttp);
var expect = chai.expect;

describe('HTTPTests', function() {

  //before(done => {
  //	/* start the socketCluster before tests*/
  //	server = sc.socketCluster;
  //  server.on('ready', function () {
  //    done();
  //  });
  //});
  //See NOTE ABOUT TESTING AT TOP OF PAGE^^ 

  //after(done => {
  //  server.killWorkers();
  //  done();
  //});
  //See NOTE ABOUT TESTING AT TOP OF PAGE^^ 

  /*All tests here*/
  describe('GET /dealers', function() {

  	it('should return "200"', function(done) {
      chai.request('http://localhost:8000')
      .get('/dealers')
      .end(function(err, res) {
        expect(res).to.have.status(200);
        done();  
      });
    });

  	it('should return text/html; charset=utf-8', function(done) {
      chai.request('http://localhost:8000')
      .get('/dealers')
      .end(function(err, res) {
        expect(res).to.be.html;
        done();  
      });
    });

  	it('should return "Sending Dealers"', function(done) {
      chai.request('http://localhost:8000')
      .get('/dealers')
      .end(function(err, res) {
        expect(res.text).to.equal('Sending Dealers\n');
        done();  
      });
    });
  });
  /*end tests*/
});
