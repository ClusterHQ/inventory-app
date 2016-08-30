"use strict";
/* Test HTTP API */

/* import libs for tests*/
var assert = require('assert');
var chai = require('chai')
  , chaiHttp = require('chai-http');

/* Import the frontend server*/
var sc = require('../server');
var server;

/* Setup needed test functions from chai*/
chai.use(chaiHttp);
var expect = chai.expect;

describe('HTTPTests', function() {


  before(done => {
  	/* start the socketCluster before tests*/
  	server = sc.socketCluster;
    server.on('ready', function () {
      done();
    });
  });

  after(done => {
    server.killWorkers();
    done();
  });

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