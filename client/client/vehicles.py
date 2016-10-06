# Copyright ClusterHQ Inc.  See LICENSE file for details.

import json
import requests

def AddVehicle(manufacturer, model, year):
    print("Adding a new vehicle")

def make_parser(parent):
    """
    Create command line parser for this module.
    """
    subparser = parent.add_parser('vehicles')
    setup_parser(subparser)
    subparser.set_defaults(func=main)

def setup_parser(parser):
    parser.add_argument('--manufacturer', required=True)

def main():
    print("Called main in vehicles")
