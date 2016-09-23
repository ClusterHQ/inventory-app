r = require('../rethink')
rdb = require('rethinkdb')

module.exports = function (req, res) {
  conn = r.connect();
	console.log('Creating a new dealership');
	console.log(req.body);
	console.log('Dealership name is ' + req.body.name);
	rdb.table('Dealership').insert(req.body).run(conn);
	res.send({message: 'hello'})
}