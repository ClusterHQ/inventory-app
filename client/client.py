import click, requests

baseurl = 'http://localhost:8000/'

@click.group()
def dealer():
    print("Entering dealership context")
    pass

@click.command()
@click.argument()
def add_dealer(name, phone, address):
    print("Adding a new dealership")
    pass

@click.command()
def remove_dealer(id):
    pass

dealer.add_command(add_dealer)

