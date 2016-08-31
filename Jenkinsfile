node ('v8s-dpcli') {
   stage 'Clean'
   sh 'sudo rm -rf inventory-app/'
   stage 'Git Clone'
   sh "git clone -b ${env.BRANCH_NAME} https://${env.GITUSER}:${env.GITTOKEN}@github.com/ClusterHQ/inventory-app"
   stage 'Ready test env'
   sh 'sudo docker-compose -f docker-compose.yml up -d'
   stage 'Build and Run Tests'
   def mochatest = docker.image('clusterhq/mochatest:latest')
   mochatest.pull() // make sure we have the latest available from Docker Hub
   mochatest.inside {
      sh 'cd inventory-app/frontend/ && sudo npm install && mocha --debug test/*'
   }
   stage 'Teardown'
   sh 'sudo docker-compose -f docker-compose.yml stop'
   sh 'sudo docker-compose -f docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'
}
