node ('v8s') {
   stage 'Clean'
   sh 'sudo rm -rf inventory-app/'
   stage 'Git Clone'
   git url: 'https://github.com/ClusterHQ/inventory-app', branch: "${env.BRANCH_NAME}"
   stage 'Ready test env'
   sh 'sudo docker run --name some-rethinkdb -p 28015:28015  -d rethinkdb'
   stage 'Build and Run Tests'
   sh 'cd inventory-app/frontend/ && sudo npm install && mocha --debug test/*'
   stage 'Teardown'
   sh 'sudo docker rm -f some-rethinkdb'
}
