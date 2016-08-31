node ('v8s') {
   stage 'Clean'
   sh 'sudo rm -rf inventory-app/'
   stage 'Git Clone'
   sh 'git clone https://wallnerryan:278a7886cf4a68a5c1b4d6c443c0bc6b630d913a@github.com/ClusterHQ/inventory-app'
   stage 'Ready test env'
   sh 'sudo docker run --name some-rethinkdb -p 28015:28015  -d rethinkdb'
   stage 'Build and Run Tests'
   sh 'cd inventory-app/frontend/ && sudo npm install && mocha --debug test/*'
   stage 'Teardown'
   sh 'sudo docker rm -f some-rethinkdb'
}
