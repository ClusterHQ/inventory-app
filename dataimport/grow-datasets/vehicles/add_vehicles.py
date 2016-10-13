#!/usr/bin/env python

# Grow dataset by POSTing to http://app:port/vehicles

import requests
import time
import csv, string
from random import randint
from random import choice
import json
import sys

def get_random_vin():
    return ''.join(choice(string.ascii_uppercase + string.digits) for _ in range(17))

def run_loop(dealer_url, vehicle_url):
        # Request http://app:port/dealerships, select random dealer + id
        r = requests.get(dealer_url)
        dealers = r.json()

        # Request http://app:port/vehicles, select random vehicle
        # and add it again as more inventory of the same vehicle.
        r = requests.get(vehicle_url)
        vehicles = r.json()

        # Loops eternally 
        while True:
            # Use existing dealers so its faster.
            dealer = randint(0, len(dealers)-1)
            dealer_id = dealers[dealer]['id']

            # Use existing vehicles so its faster.
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

            # Delay 50 milliseconds.
            # time.sleep(50.0 / 1000.0)

            # Make Request to Add Vehicle
            r = requests.post(vehicle_url, json=vehicle_dict)
            if r.status_code == 201:
                print("Added Vehicle: %s" % json.dumps(vehicle_dict))
            else:
                print("Failed to add Vehicle: %s" % json.dumps(vehicle_dict))
                print(r.status_code)

def main(args):
    if len(args) == 0:
        print("Usage: add_vehicles.py <http://API_URL:PORT>")
    elif len(args) == 1:
        dealer_url="%s/dealerships" % args[0]
        vehicle_url="%s/vehicles" % args[0]
        run_loop(dealer_url, vehicle_url)
    else:
        print("Usage: add_vehicles.py <http://API_URL:PORT>")

if __name__ == '__main__':
    main(sys.argv[1:])