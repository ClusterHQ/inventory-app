# How to import data and create an initial snapshot

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
   dpcli create snapshot --volume <volume-used-in-docker-compose> --branch <branch> --message <message>
   dpcli push <snapshot-created-above>
```

### Destroy the environment
```
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'
```


## Switch between Bulk import vs Record by Record

Change the `Dockerfile.bulk.sav` in the appropriate directory to `Dockerfile`

>Note: bulk operations were ~20s and ~29s vs ~1min and ~2min 45s for non-bulk in testing.

### Examples in Jenkins

Re-instantiate the database and use a record by record import/insert into RethinkDB and run 3 isolated tests
http://ec2-54-173-56-41.compute-1.amazonaws.com:8080/job/inventory-pipeline-multi/job/recordbyrecord_example/
  - Average Runtime: 10-12min
  - https://github.com/ClusterHQ/inventory-app/tree/recordbyrecord_example

Re-instantiate the database and use  a bulk import/insert into RethinkDB and run 3 isolated tests
http://ec2-54-173-56-41.compute-1.amazonaws.com:8080/job/inventory-pipeline-multi/job/bulk_example/
  - Average Runtime: 5-6 mins
  - https://github.com/ClusterHQ/inventory-app/tree/bulk_example