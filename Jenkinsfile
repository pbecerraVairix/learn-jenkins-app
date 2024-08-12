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
        stage('E2E'){
            agent{
                docker{
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            steps{
                sh '''
                    npm install serve
                    node_modules/.bin/serve -s build & 
                    sleep 10
                    npx playwright test --reporter=html
                '''
                // first it will be a server instaled (the build stage is necesary) and then a test with playworght will be used
            }
        }
    }

    post{
        always{ //it will run with success and error
            junit 'jest-results/junit.xml' //creates a JUnit test report
        }
    }
}
