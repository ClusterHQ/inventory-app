import rethinkdb as rdb
import json
from urllib.request import urlretrieve
from os import environ

### The name of the table that will be created in the RethinkDB instance
table_name = 'dealers'
file_name = 'data.json'

### Define the host for the database (default to localhost)
dbhost = environ['DATABASE_HOST'] if 'DATABASE_HOST' in environ.keys() else 'localhost'

### Connect to the RethinkDB instance
try:
    dbconn = rdb.connect('localhost')
    print("Connected to RethinkDB")
except:
    print("Could not establish connection to database service on {0}.".format(dbhost))
    exit(10)

def download_data(fname):
    args = {
        'url': 'https://data.ct.gov/api/views/apne-w8c6/rows.json',
        'filename': fname
    }
    urlretrieve(**args)
    print('Finished downloading dealership data to file: {0}'.format(fname))

def create_table_if_not_exists(tname):
    if tname in rdb.table_list().run(dbconn):
        print('Table ''{0}'' already exists in RethinkDB instance. Skipping creation ...'.format(tname))
    else:
        rdb.table_create(tname).run(dbconn)
        print('Created {0} table in RethinkDB instance'.format(tname))

def import_data(tname, fname):
    with open(fname) as file:
        ### Load the JSON data
        dealerdata = json.load(file)

        ### Iterate over dealerships and add them to the database
        for dealer in dealerdata["data"]:
            address = json.loads(dealer[13][0])
            new_dealer = {
                "name": dealer[8],
                "addr": '{0} {1}, {2} {3}'.format(dealer[9], address["city"], address["state"], dealer[11]),
                "phone": '555-555-5555'
            }
            rdb.table(tname).insert(new_dealer).run(dbconn)
            print("Added dealer {0}".format(new_dealer['name']))

download_data(file_name)
create_table_if_not_exists(table_name)
import_data(table_name, file_name)