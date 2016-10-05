# Copyright ClusterHQ Inc.  See LICENSE file for details.
"""
Executed with 'python -m <packageName>'.
Cannot be imported as a regular module.
"""
if __name__ != '__main__':
    raise ImportError('This module cannot be imported in a Python script.')

baseurl = 'http://localhost:8000/'

import argparse #noqa
import sys #noqa

from client import connection, dealerships, vehicles

PARSER = argparse.ArgumentParser(description='Primary argument parser', prog='Specify the desired sub-command.')
SUBPARSERS = PARSER.add_subparsers()
connection.make_parser(SUBPARSERS)
dealerships.make_parser(SUBPARSERS)
vehicles.make_parser(SUBPARSERS)

args = PARSER.parse_args()
args.func(args)