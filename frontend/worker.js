var fs = require('fs');
var express = require('express');
var serveStatic = require('serve-static');
var path = require('path');
var dummyData = require('./sc_modules/dummy-data');
var authentication = require('./sc_modules/authentication');
var scCrudRethink = require('sc-crud-rethink');

module.exports.run = function (worker) {
  console.log('   >> Worker PID:', process.pid);

  var httpServer = worker.httpServer;
  var scServer = worker.scServer;

  // Use ExpressJS to handle serving static HTTP files
  var app = require('express')();
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
      Category: {
        fields: {
          id: type.string(),
          name: type.string(),
          desc: type.string().optional()
        },
        views: {
          alphabeticalView: {
            transform: function (fullTableQuery, r) {
              return fullTableQuery.orderBy(r.asc('name'));
            }
          }
        },
        filters: {
          pre: mustBeLoggedIn
        }
      },
      Product: {
        fields: {
          id: type.string(),
          name: type.string(),
          qty: type.number().integer().optional(),
          price: type.number().optional(),
          desc: type.string().optional(),
          category: type.string()
        },
        views: {
          categoryView: {
            // Declare the fields from the Product model which are required by the transform function.
            paramFields: ['category'],
            transform: function (fullTableQuery, r, productFields) {
              // Because we declared the category field above, it is evailable in here.
              // This allows us to tranform/filter the Product collection based on a specific category
              // ID provided by the frontend.
              return fullTableQuery.filter(r.row('category').eq(productFields.category)).orderBy(r.asc('qty'))
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
};
