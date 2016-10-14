#!/usr/bin/env python

# Grow dataset by POSTing to http://app:port/dealers

import requests
import time
import json
import csv
import sys
from faker import Faker
fake = Faker()

def get_random_dealer_name():
    name1 = str(fake.name())
    name2 = str(fake.name())
    name3 = str(fake.name())
    # introduce some randomness by using
    # more than one name
    dealership = "%s's, %s's & %s's Auto Dealership" % (name1, name2, name3)
    return dealership

def get_random_address():
    return str(fake.address()).replace("\n", " ")

def run_loop(url):
    # Loops eternally
    while True:
        # Create a Dealer

        name = get_random_dealer_name()
        # Faker Factory has phone_number
        # fake.phone_number() but hard to get
        # a specific format.
        phone = "555-555-5555"
        addr = get_random_address()

        dealer = {
            "name": name,
            "phone": phone,
            "addr": addr
        }

        # Delay 1 Second
        # time.sleep(1)

        # POST Request to add Dealer
        r = requests.post(url, json=dealer)
        if r.status_code == 201:
            print("Added Dealer: %s" % json.dumps(dealer))
        else:
            print("Failed to add Dealer: %s" % json.dumps(dealer))
            print(r.status_code)


def main(args):
    if len(args) == 0:
        print("Usage: add_dealers.py <http://API_URL:PORT>")
    elif len(args) == 1:
        dealer_url="%s/dealerships" % args[0]
        run_loop(dealer_url)
    else:
        print("Usage: add_dealers.py <http://API_URL:PORT>")

if __name__ == '__main__':
    main(sys.argv[1:])
