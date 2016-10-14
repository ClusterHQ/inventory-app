var fs = require('fs');
var express = require('express');
var serveStatic = require('serve-static');
var path = require('path');
var dummyData = require('./sc_modules/dummy-data');
var httpHandler = require('./sc_modules/http-handler')
var authentication = require('./sc_modules/authentication');
var scCrudRethink = require('sc-crud-rethink');
var bodyParser = require('body-parser')

module.exports.run = function (worker) {
  console.log('   >> Worker PID:', process.pid);

  var httpServer = worker.httpServer;
  var scServer = worker.scServer;

  // Use ExpressJS to handle serving static HTTP files
  var app = require('express')();
  app.use(bodyParser.json())
  app.use(serveStatic(path.resolve(__dirname, 'public')));
  httpServer.on('request', app);

  /*
    Here we attach some modules to scServer - Each module injects their own logic into the scServer to handle
    a specific aspect of the system/business logic.
  */

  var thinky = scCrudRethink.thinky;
  var type = thinky.type;

  var crudOptions = {
    defaultPageSize: 5,
    schema: {
      Dealership: {
        fields: {
          id: type.string(),
          name: type.string(),
          addr: type.string().optional(),
          phone: type.string().optional(),
          desc: type.string().optional()
        },
        views: {
          alphabeticalView: {
            transform: function (fullTableQuery, r) {
              // This should really return the ammount of dealerships
              // per page. E.g. user is on page 1, return first 100,
              // page 2, second 100, and so on. But havent implemented it.
              // without this limit, we hit timeout errors b/c of too
              // many records, or
              return fullTableQuery.orderBy({index: 'id'});
            }
          }
        },
        filters: {
          pre: mustBeLoggedIn
        }
      },
      Vehicle: {
        fields: {
          id: type.string(),
          make: type.string(),
          model: type.string(),
          year: type.number(),
          vin:  type.string(),
          dealership: type.string()
        },
        views: {
          dealershipView: {
            // Declare the fields from the Dearlship model which are required by the transform function.
            paramFields: ['dealership'],
            transform: function (fullTableQuery, r, vehicleFields) {
              // Because we declared the dealer field above, it is available in here.
              // This allows us to tranform/filter the Product collection based on a specific dealer
              // ID provided by the frontend.
              // Artificially limit # of vehicles as to avoid timeouts on verhicle records
              // which can easily be greater than 1Mil
              return fullTableQuery.orderBy({index: 'id'}).filter(r.row('dealership').eq(vehicleFields.dealership))
              //return fullTableQuery.filter(r.row('dealership').eq(vehicleFields.dealership))
            }
          }
        },
        filters: {
          pre: mustBeLoggedIn,
          post: postFilter
        }
      },
      User: {
        fields: {
          username: type.string(),
          password: type.string()
        },
        filters: {
          pre: mustBeLoggedIn
        }
      }
    },

    thinkyOptions: {
      host: process.env.DATABASE_HOST || '127.0.0.1',
      port: process.env.DATABASE_PORT || 28015
    }
  };

  function mustBeLoggedIn(req, next) {
    if (req.socket.getAuthToken()) {
      next();
    } else {
      next(true);
      req.socket.emit('logout');
    }
  }

  function postFilter(req, next) {
    // The post access control filters have access to the
    // resource object from the DB.
    // In case of read actions, you can even modify the
    // resource's properties before it gets sent back to the user.
    // console.log('r', !!req.r.table);
    // console.log('action', req.action);
    // console.log('socket', req.socket.id);
    // console.log('authToken', req.authToken);
    // console.log('query', req.query);
    // console.log('resource', req.resource);
    // console.log('-------');
    // if (req.resource.name == 'Foo') {
    //   var err = new Error('MAJOR FAIL');
    //   err.name = 'MajorFailError';
    //   next(err);
    //   return;
    // }
    next();
  }

  var crud = scCrudRethink.attach(worker, crudOptions);
  scServer.thinky = crud.thinky;

  // Add some dummy data to our store
  dummyData.attach(scServer, crud);

  /*
    In here we handle our incoming realtime connections and listen for events.
  */
  scServer.on('connection', function (socket) {
    /*
      Attach some modules to the socket object - Each one decorates the socket object with
      additional features or business logic.
    */

    // Authentication logic
    authentication.attach(scServer, socket);
  });

  /*
  Add basic HTTP REST API
  */
  httpHandler.attach(app);

};
