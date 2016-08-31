node ('v8s') {
   stage 'Clean'
   sh 'sudo rm -rf inventory-app/'
   stage 'Git Clone'
   sh "git clone https://${GITUSER}:${GITTOKEN}@github.com/ClusterHQ/inventory-app"
   stage 'Ready test env'
   sh 'sudo docker run --name some-rethinkdb -p 28015:28015  -d rethinkdb'
   stage 'Build and Run Tests'
   sh 'cd inventory-app/frontend/ && sudo npm install && mocha --debug test/*'
   stage 'Teardown'
   sh 'sudo docker rm -f some-rethinkdb'
}
