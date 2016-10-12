#!/usr/bin/env python

# Grow dataset by POSTing to http://app:port/vehicles

# Dealers are added less often in real life, so we will
# introduce an artificial delay in adding them, this allows
# vehicles to be added more rapidly in comparison to Dealers
# and we can use less of a delay for Vehicles.
import requests
import time
import csv, string
from urllib.request import urlretrieve
from random import randint
from random import choice
import json

def get_random_vin():
    return ''.join(choice(string.ascii_uppercase + string.digits) for _ in range(17))

def run_loop(dealer_url, vehicle_url):

        # Loops eternally 
        while True:
            # Request http://app:port/dealerships, select random dealer + id
            r = requests.get(dealer_url)
            dealers = r.json()
            dealer = randint(0, len(dealers)-1)
            dealer_id = dealers[dealer]['id']

            # Request http://app:port/vehicles, select random vehicle
            # and add it again as more inventory of the same vehicle.
            r = requests.get(vehicle_url)
            vehicles = r.json()
            vehicle = randint(0, len(vehicles)-1)
            vehcle_data = vehicles[vehicle]


            # Create a Vehicle

            # //Create a "fake" Vehicle.//
            # Select random Make from csv.
            make = vehcle_data['make']
            # Select random Model from csv.
            model = vehcle_data['model']
            # Select random Year from csv.
            year = vehcle_data['year']
            # Select VIN (modify it slightly) from csv.
            vin = get_random_vin()

            vehicle_dict = {
                  "dealership": dealer_id,
                  "make": make,
                  "model": model,
                  "vin": vin,
                  "year": year
                }

            print(vehicle)

            # Delay X seconds.
            time.sleep(1)

            # Make Request to Add Vehicle
            r = requests.post(vehicle_url, json=vehicle_dict)
            if r.status_code == 201:
                print("Added Vehicle: %s" % json.dumps(vehicle_dict))
            else:
                print("Failed to add Vehicle: %s" % json.dumps(vehicle_dict))
                print(r.status_code)

def main():
    dealer_url="http://ec2-54-237-204-239.compute-1.amazonaws.com:32787/dealerships"
    vehicle_url="http://ec2-54-237-204-239.compute-1.amazonaws.com:32787/vehicles"

    run_loop(dealer_url, vehicle_url)

if __name__ == '__main__':
    main()