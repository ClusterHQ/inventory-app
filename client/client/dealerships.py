# Copyright ClusterHQ Inc.  See LICENSE file for details.

import requests
import argparse
from . import connection

def AddDealership(name, phone, address):
    print("Creating a new dealership, name: {name}, phone: {phone}, address: {address}".format(name=name, phone=phone, address=address))
    method = '{}/dealerships'.format(connection.GetEndpoint())
    requests.post(method, data={
        'name': name,
        'phone': phone,
        'addr': address
    })

def make_parser(parent):
    """
    Create command line parser for this module.
    """
    subparser = parent.add_parser('dealerships', aliases=['dealer'])
    setup_parser(subparser)
    subparser.set_defaults(func=main)

def setup_parser(parser):
    """
    Sets up the parameters for this module.
    """
    parser.add_argument('--name', required=True, help='The name of the dealership', metavar='DealerName')
    parser.add_argument('--phone', required=True, help='The phone number for the dealership', metavar='DealerPhone')
    parser.add_argument('--address', required=True, help='The address of the dealership', metavar='DealerAddress')

def main(args):
    print("Called main in dealerships")
    AddDealership(args.name, args.phone, args.address)