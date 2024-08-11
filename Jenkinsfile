pipeline {
    agent any

    stages {
        stage('Build') {
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo "Build stage"
                    ls -la
                    node --version
                    npm --version
                    npm ci 
                    npm run build
                    ls -la
                '''
                //'node ci' is like npm install
            }
        }
        stage('Test'){
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps{
                sh '''
                    echo "Test stage"
                    if test -f build/index.html
                    then
                        echo "file exists"
                    else
                        echo "file doesn't exist"
                        exit 2
                    fi
                npm test
                '''
                // npm test will run some tests after the build stage
            }
        }
    }
}
