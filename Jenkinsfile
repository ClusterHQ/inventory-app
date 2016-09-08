node ('v8s-dpcli') {
   stage 'Clean'
   sh 'sudo rm -rf inventory-app/'
   stage 'Git Clone'
   sh "git clone -b ${env.BRANCH_NAME} https://${env.GITUSER}:${env.GITTOKEN}@github.com/ClusterHQ/inventory-app"
   stage 'Ready test env'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml up -d --build'
   stage 'Load the Dealer data'
   sh 'cd inventory-app/dataimport/dealerships/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:dealerimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:dealerimport-0.1'
   stage 'Load the Vehicle data'
   sh 'cd inventory-app/dataimport/vehicles/ && sudo docker build --file Dockerfile --no-cache --tag clusterhq/inventory-app:vehicleimport-0.1 .'
   sh 'sudo docker run --rm --net=host clusterhq/inventory-app:vehicleimport-0.1'
   stage 'Build and Run Tests'
   sh 'sudo docker run --net=host --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest "cd /app/frontend && npm install && mocha --debug test/*.js"'
   stage 'Teardown'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -f inventory-app/docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'
   stage 'Pull snapshot'
   def vs = '1734c879-641c-41cd-92b5-f47704338a1d'
   def snap = '7d3fca7e-376b-4a0d-a6a9-ffa7c4a333ae'
   def ep = 'http://ec2-54-234-205-145.compute-1.amazonaws.com'
   sh "sudo sh inventory-app/utils/use_snap.sh ${vs} ${snap} ${ep}"
   stage "Start with snapshot"
   sh "cat inventory-app/docker-compose.yml"
}
