module.exports.attach = function (scServer, scCrudRethink) {
  /*
    Add some dummy data to RethinkDB;
  */

  scCrudRethink.read({
    type: 'User'
  }, function (err, result) {
    if (err) {
      console.error(err);
      return;
    }


    // If there is no User data, assume that we are starting with
    // an empty database.
    if (!result.data.length) {
      var schema = {
        Dealership: {
          foreignKeys: {
            vehicles: 'Vehicle'
          }
        }
      };

      var dealerships = {
        
      };

      Object.keys(dealerships).forEach(function (id) {
        var obj = dealerships[id];
        scCrudRethink.create({
          type: 'Dealership',
          value: obj
        });
      });

      var users = {
        'bob': {
          username: 'bob',
          password: 'password123'
        }
      };

      Object.keys(users).forEach(function (id) {
        var obj = users[id];
        scCrudRethink.create({
          type: 'User',
          value: obj
        });
      });
    }
  });
};
