# Import data, create an initial snapshot, grow datasets overtime.

### Git clone the repository
```
   # Clone the inventory app with the Github Bot user.
   git clone https://github.com/ClusterHQ/inventory-app
```

### Pull a snapshot, create the volume and add the path to compose.
```
dpcli create volume <volumeset>
vi docker-compose.yml
	#(replace "rethink-data:/data" with "/chq/<volume>/:/data")
```

### Start the app + db

`-p inventory` gives the network name `inventory_net`, without it, the imports wont work.

```
   docker-compose -p inventory -f inventory-app/docker-compose.yml up -d --build
```

### Load the data
```
   cd inventory-app/dataimport/dealerships/

   # Load the dealer data
   docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:dealerimport-0.1 .
   docker run --rm --net=host clusterhq/inventory-app:dealerimport-0.1

   # Load the vehicle data
   docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:vehicleimport-0.1 .
   docker run --rm --net=host clusterhq/inventory-app:vehicleimport-0.1
```

### Take a snapshot
```
   fli snapshot <volumeset>:<volume-used-in-docker-compose> --branch <branch>
   fli push <volumeset>:<snapshot-created-above>
```

### Destroy the environment
```
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'
```

