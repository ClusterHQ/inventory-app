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

