import csv
import os
import random
import string
import sys

import rethinkdb as rdb
import requests

def download_data(file_url, fname):
    r = requests.get(file_url)
    with open(fname, 'w') as fp:
        fp.write(r.content)
    print('Finished downloading vehicles data to file: {0}'.format(fname))

def create_table_if_not_exists(dbconn, tname):
    if tname in rdb.table_list().run(dbconn):
        print('Table ''{0}'' already exists in RethinkDB instance. Skipping creation ...'.format(tname))
        return
    rdb.table_create(tname).run(dbconn)
    print('Created {0} table in RethinkDB instance'.format(tname))

def get_dealers(dbconn):
    dealers = rdb.table("Dealership").run(dbconn)
    valid_dealers = [dealer for dealer in dealers if dealer['id'] and dealer['name']]
    return valid_dealers

def get_random_dealer_id(dealers):
    dealer = random.choice(dealers)
    return dealer['id'], dealer['name']

def get_random_vin():
    return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(17))

def import_data(dbconn, tname, fname, dealers):
    with open(fname) as csvfile:
        ### Load the JSON data
        vehicles = csv.reader(csvfile, delimiter=',')

        ### Iterate over vehicles and add them to the database
        for row in vehicles:
            d_id, d_name = get_random_dealer_id(dealers)
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

def main():
    table_name = 'Vehicle'
    file_url = "https://s3.amazonaws.com/v8sdemoapp/2010-2016vehicles.csv"
    file_name = os.path.basename(file_url)

    ### Define the host for the database (default to localhost)
    dbhost = os.environ.get('DATABASE_HOST',  'localhost')

    ### Connect to the RethinkDB instance
    try:
        dbconn = rdb.connect(dbhost)
        print("Connected to RethinkDB")
    except rdb.errors.ReqlDriverError:
        sys.exit("Could not establish connection to database service on {0}.".format(dbhost))
    download_data(file_url, file_name)
    create_table_if_not_exists(dbconn, table_name)
    # load dealers into memory for speed.
    dealers = get_dealers(dbconn)
    import_data(dbconn, table_name, file_name, dealers)

if __name__ == '__main__':
    main()
