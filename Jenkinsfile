node ('v8s-dpcli') {
   stage 'Clean'
   sh 'sudo rm -rf inventory-app/'
   stage 'Git Clone'
   sh "git clone -b ${env.BRANCH_NAME} https://${env.GITUSER}:${env.GITTOKEN}@github.com/ClusterHQ/inventory-app"
   stage 'Ready test env'
   sh 'cd inventory-app/ && sudo /usr/local/bin/docker-compose -f docker-compose.yml up -d'
   stage 'Build and Run Tests'
   sh 'sudo docker run --rm -v ${PWD}/inventory-app/:/app/ clusterhq/mochatest "cd /app/frontend && npm install && mocha --debug test/*.js"'
   stage 'Teardown'
   sh 'sudo /usr/local/bin/docker-compose -H unix:///var/run/docker.sock -f docker-compose.yml stop'
   sh 'sudo /usr/local/bin/docker-compose -H unix:///var/run/docker.sock -f docker-compose.yml rm -f'
   sh 'sudo docker volume rm inventoryapp_rethink-data'
}
