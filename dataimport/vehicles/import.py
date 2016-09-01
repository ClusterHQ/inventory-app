import rethinkdb as rdb
from urllib.request import urlretrieve
from os import environ
import csv

### The name of the table that will be created in the RethinkDB instance
table_name = 'Vehicle'
file_name = '2010-2016vehicles.csv'
file_url = "https://s3.amazonaws.com/v8sdemoapp/2010-2016vehicles.csv"

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
        'url': file_url,
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
    with open(fname) as csvfile:
        ### Load the JSON data
        vehicles = csv.reader(csvfile, delimiter=',')

        ## ****LEFT OFF HERE, TODO Below ******

        ### Iterate over dealerships and add them to the database
        for dealer in dealerdata["data"]:
            address = json.loads(dealer[13][0])
            new_dealer = {
                "name": dealer[8],
                "street": dealer[9],
                "city": address["city"],
                "state": address["state"],
                "zip": dealer[11]
            }
            rdb.table(tname).insert(new_dealer).run(dbconn)
            print("Added dealer {0}".format(new_dealer['name']))

download_data(file_name)
create_table_if_not_exists(table_name)
import_data(table_name, file_name)
