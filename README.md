# ClusterHQ Inventory Application

This sample application is intended to demonstrate core use cases for the ClusterHQ Flocker Hub product.
The application's primary purpose is to track fake vehicle inventory at fake car dealerships.

A sample inventory tracking realtime single page app built with SocketCluster (http://socketcluster.io/), Google's Polymer (v1.0) Framework and RethinkDB.
It demonstrates a way of building realtime apps.

All code for the server-side worker logic is linked from worker.js - It's mostly generic so feel free to reuse/modify for your own app
or you can use this app as a base to build yours if starting from scratch.

Aside from SocketCluster, Polymer and RethinkDB, this sample app uses the following modules:
- sc-collection (https://github.com/SocketCluster/sc-collection - ```bower install sc-collection --save```)
- sc-field (https://github.com/SocketCluster/sc-field - ```bower install sc-field --save```)
- sc-crud-rethink (https://github.com/SocketCluster/sc-crud-rethink - ```npm install sc-crud-rethink --save```)

This sample app aims to demonstrate all the cutting edge features that one might want when
building a realtime single page app including:

- Authentication (via JWT tokens)
- Access control using backend middleware
- Reactive data binding
- Realtime REST-like interface
- Pagination with realtime updates

## Components

In the subsections below, we'll discuss the individual components that make up this application.

### Front-End

The web front-end component is a Dockerized Node.js application.

### Database

This sample application uses RethinkDB, an open source document-based database platform that stores JSON objects.
RethinkDB runs inside a Docker container, along with the other application components.
There is a web front-end that provides for data query operations and monitoring reads + writes to the RethinkDB instance / cluster at a high level.  

### Logging

Logging is an essential component of any application, including this ClusterHQ inventory tracking application. 
Due to its simplicity, Syslog is used for logging.

### Data Import

Because the application starts fresh, with a completely empty RethinkDB instance, we need to seed the database with some useful data.
Once the data is seeded into the database, you can use the front-end component to view the data.

To seed the data, there are data import applications under the `\dataimport` directory in this project.

- Dealership Import - imports a list of ~5,400 car dealerships
- Vehicle Import - randomly creates vehicles and associates them to dealerships

The data import applications are executed as one-time Docker containers.
Running the data import containers more than once, against a given RethinkDB instance, may cause unpredictable results.
We recommend running these scripts only once against a given RethinkDB instance. 
To run these data import programs, use these commands:

```bash
./dataimport/dealerships/DockerBuild.sh
./dataimport/vehicles/Dockerbuild.sh
```

## Data Models

The data models at use in this project are described below.

### Dealership

Each car dealership has the following properties:

- `[string] id` - A unique ID for the dealership, automatically assigned by RethinkDB
- `[string] name` - The name of the car dealership
- `[string] addr` - Street, City, State, ZIP for car dealership
- `[string] phone` - Phone number for the car dealership

### Vehicle

Each vehicle has the following properties:

- `[string] dealership` - (foreign key reference to `Dealership.id` field)
- `[string] make` - The manufacturer (make) of the vehicle 
- `[string] model` - The model of the vehicle
- `[string] year` - The year the vehicle was manufactured
- `[string] vin` - The unique, fake VIN of the vehicle (not actually a valid standard VIN)

## Installation

### Prerequisites

Before you can run this sample application, make sure that you meet these prerequisites:

- Make sure you have Git installed (https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- Make sure you have Docker Compose installed
- Make sure that you have access to a Docker Host from the `docker` CLI (use `docker version` to confirm connectivity)

### Sample Application Execution

To start up the sample application, run through these steps:

- ```git clone https://github.com/ClusterHQ/inventory-app.git```
- Navigate to the `inventory-app/` directory
- Run `docker-compose up -d` to run the containers silently

### Accessing the Application

- Navigate to `https://localhost:8000` to access the application's web front-end
- Navigate to `https://localhost:8080` to access the RethinkDB web console (optional)
