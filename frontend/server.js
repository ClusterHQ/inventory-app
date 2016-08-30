var argv = require('minimist')(process.argv.slice(2));
var SocketCluster = require('socketcluster').SocketCluster;

var socketCluster = new SocketCluster({
  workers: Number(argv.w) || 1,
  brokers: Number(argv.b) || 1,
  port: Number(argv.p) || 8000,
  authKey: 'todo',
  appName: argv.n || null,
  workerController: __dirname + '/worker.js',
  brokerController: __dirname + '/broker.js',
  socketChannelLimit: 100,
  rebootWorkerOnCrash: argv['auto-reboot'] != false,
  pingTimeout: 5000,
  pingInterval: 2000
});
  
/* 
Allows us to import this into tests
and use the real worker and DB connections
*/
exports.socketCluster = socketCluster;