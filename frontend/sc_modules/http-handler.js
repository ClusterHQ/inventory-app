module.exports.attach = function (expressApp) {
    // Setup HTTP/REST API for Server Side.

    // Simple GET /dealers for testing HTTP
    expressApp.get('/dealers',(req,res) => {
        console.log('recieved dealers request')
        /* 
         Add something useful, like a json response of dealers
         We can easily add tests for this.
        */
   	    res.send('Sending Dealers\n')
  	})

   /* TODO, remove from list when complete */

   //(POST) Dealership(s)
   //(POST) vehicles to Dealership(s)
   //(DELETE) Remove vehicles from Dealership(s)
   //(GET) All Dealerships
   //(GET) A Dealerships
   //(GET) All Vehicles
   //(GET) A Vehicle
};