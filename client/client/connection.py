# Copyright ClusterHQ Inc.  See LICENSE file for details.

import json
import os

def SetEndpoint(string endpoint):
    """
    Sets an environment variable to define the URI of the inventory app API
    and writes the endpoint to a JSON file.
    """
    json.dumps({
        'endpoint': endpoint
    })
    os.environ['INVAPPENDPOINT'] = endpoint

def GetConfigHandle():
    home = os.path.expanduser('~')    
    return open('{0}\.inventory_app.json'.format(home))