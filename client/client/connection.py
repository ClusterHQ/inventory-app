# Copyright ClusterHQ Inc.  See LICENSE file for details.

import json
import os

### Specify the fully qualified path to the configuration file
configpath = '{}\.inventory_app.config.json'.format(os.path.expanduser('~'))
connectionVar = 'INVAPPENDPOINT'

def SetEndpoint(endpoint):
    """
    Sets an environment variable to define the URI of the inventory app API
    and writes the endpoint to a JSON file.
    """
    file = GetConfigHandle()
    file.write(json.dumps({
        'endpoint': endpoint
    }))
    os.environ[connectionVar] = endpoint
    file.close()

def GetEndpoint():
    """
    Get the connection endpoint.
    """
    endpoint = os.environ.get(connectionVar)
    if endpoint == None:
        raise "Please specify a connection endpoint."
    else:
        return endpoint

def GetConfigHandle():
    home = os.path.expanduser('~')    
    return open('{0}\.inventory_app.json'.format(home), mode='w')

def make_parser(parent):
    """
    Create command line parser for this module.
    """
    subparser = parent.add_parser('connection')
    setup_parser(subparser)
    subparser.set_defaults(func=main)

def setup_parser(parser):
    parser.add_argument('--endpoint', help='The prefix of the endpoint (eg. https://localhost:8000)')

def main(args):
    print("Called main in connection")
    SetEndpoint(args.endpoint)