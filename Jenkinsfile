pipeline {
    agent any

    environment{
        NETLIFY_SITE_ID = 'fa0f0dce-c950-4ebd-9d22-1a06e41f8934' //ID from Netlify to connect 
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {
        stage('Docker'){
            steps{
                sh'docker build -t my-playwright .'
                //my-playwright will be the name of the docker build. It can be used in other stages
            }
        }

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
                            image 'my-playwright'
                            reuseNode true
                        }
                    }
                    steps{
                        sh '''
                            serve -s build & 
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                        // the other steps are not necesary because they are running in Netlify
                    }

                    post{
                        always{ //it will run with success and error
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local', reportTitles: '', useWrapperFileDirectly: true])
                            //this line it's generated with the Pipeline Syntax 
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            agent{
                docker{
                    image 'my-playwright'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    netlify --version
                    echo "Deploying to production. Site ID: $NETLIFY_SITE_ID"
                    netlify status
                    netlify deploy --dir=build --prod
                '''
                //--dir sets the directory to deploy
                //--prod deploy to production
            }
        }
        stage('Production E2E'){
            agent{
                docker{
                    image 'my-playwright'
                    reuseNode true
                }
            }

            environment{
                CI_ENVIRONMENT_URL = 'https://66ba3d602c58d1d77723caf0--delightful-tartufo-ff34b0.netlify.app'
            }
            //This variable is used in playwright.config.
            //This is necesary in order to let know Netlify where the tests must be run.

            steps{
                sh '''
                    npx playwright test --reporter=html
                '''
                // first it will be a server instaled (the build stage is necesary) and then a test with playworght will be used
            }

            post{
                always{ //it will run with success and error
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright E2E', reportTitles: '', useWrapperFileDirectly: true])
                    //this line it's generated with the Pipeline Syntax 
                }
            }
        }
    }      
}
