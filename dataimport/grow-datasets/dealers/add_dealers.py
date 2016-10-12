#!/usr/bin/env python

# Grow dataset by POSTing to http://app:port/dealers

# Dealers are added less often in real life, so we will
# introduce an artificial delay in adding them, this allows
# vehicles to be added more rapidly in comparison to Dealers.
import requests
import time
import json
from urllib.request import urlretrieve
import csv
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

        # Delay X Seconds
        time.sleep(5)

        # POST Request to add Dealer
        r = requests.post(url, json=dealer)
        if r.status_code == 201:
            print("Added Dealer: %s" % json.dumps(dealer))
        else:
            print("Failed to add Dealer: %s" % json.dumps(dealer))
            print(r.status_code)


def main():
    app_url="http://ec2-54-237-204-239.compute-1.amazonaws.com:32787/dealerships"

    run_loop(app_url)


if __name__ == '__main__':
    main()
