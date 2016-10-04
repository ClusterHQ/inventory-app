#!/usr/bin/env python

### Documentation for setup.py can be found here: https://docs.python.org/3.5/distutils/setupscript.html

from distutils.core import setup

setup(name='InventoryAppClient',
      version='1.0',
      description='A command line client companion for the ClusterHQ Inventory Application sample app.',
      author='Trevor Sullivan, Ryan Wallner',
      author_email='trevor@clusterhq.com, ryan@clusterhq.com',
      url='https://github.com/clusterhq/inventory-app',
      packages=['client'],
     )