pipeline {
    agent any

    environment{
        NETLIFY_SITE_ID = 'fa0f0dce-c950-4ebd-9d22-1a06e41f8934' //ID from Netlify to connect 
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

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
        
        stage('Tests'){
            parallel{ //to run stages in parallel
                stage('Unit test'){
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
                    post{
                        always{ //it will run with success and error
                            junit 'jest-results/junit.xml' //creates a JUnit test report
                        }
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

                    post{
                        always{ //it will run with success and error
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                            //this line it's generated with the Pipeline Syntax 
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            agent{
                docker{
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                '''
            }
        }
    }      
}
