import rethinkdb as rdb
from urllib.request import urlretrieve
from os import environ
from random import randint
from random import choice
import csv, string

### The name of the table that will be created in the RethinkDB instance
table_name = 'Vehicle'
file_name = '2010-2016vehicles.csv'
file_url = "https://s3.amazonaws.com/v8sdemoapp/2010-2016vehicles.csv"

### Define the host for the database (default to localhost)
dbhost = environ['DATABASE_HOST'] if 'DATABASE_HOST' in environ.keys() else 'localhost'

### Connect to the RethinkDB instance
try:
    dbconn = rdb.connect(dbhost)
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
    print('Finished downloading vehicles data to file: {0}'.format(fname))

def create_table_if_not_exists(tname):
    if tname in rdb.table_list().run(dbconn):
        print('Table ''{0}'' already exists in RethinkDB instance. Skipping creation ...'.format(tname))
    else:
        rdb.table_create(tname).run(dbconn)
        print('Created {0} table in RethinkDB instance'.format(tname))

dealers = None
def get_dealers():
    global dealers
    dealers = rdb.table("Dealership").run(dbconn)
    dealers = list(dealers)

def get_random_dealer_id():
    dealer = randint(0, len(dealers)-1)
    if 'id' in dealers[dealer] and 'name' in dealers[dealer]:
        return (dealers[dealer]['id'], dealers[dealer]['name'])
    else:
        # recursive call to get valid dealer
        get_random_dealer_id()

def get_random_vin():
    return ''.join(choice(string.ascii_uppercase + string.digits) for _ in range(17))

def import_data(tname, fname):
    with open(fname) as csvfile:
        ### Load the JSON data
        vehicles = csv.reader(csvfile, delimiter=',')

        ### Iterate over vehicles and add them to the database
        for row in vehicles:
            d_id, d_name = get_random_dealer_id()
            vin = get_random_vin()
            new_vehicle = {
                "dealership":  d_id,
                "make":  row[1],
                "model":  row[2],
                "vin": vin,
                "year": row[0]
            }
            rdb.table(tname).insert(new_vehicle).run(dbconn)
            print("Added Vehicle {0} {1} {2} to dealership {3}".format(new_vehicle['make'],
                                                     new_vehicle['model'],
                                                     new_vehicle['year'],
                                                     d_name))
download_data(file_name)
create_table_if_not_exists(table_name)
# load dealers into memory for speed.
get_dealers()
import_data(table_name, file_name)
