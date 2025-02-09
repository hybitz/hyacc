pipeline {
  agent none
  environment {
    KANIKO_OPTIONS = "--cache=${CACHE} --compressed-caching=false --build-arg registry=${ECR}"
    APP_NAME = 'hyacc'
  }
  stages {
    stage('build') {
      agent { kubernetes { inheritFrom 'kaniko' } }
      steps {
        container('kaniko') {
          ansiColor('xterm') {
            sh '/kaniko/executor -f `pwd`/Dockerfile.base -c `pwd` -d=${ECR}/${APP_NAME}/base:latest ${KANIKO_OPTIONS}'
            sh '/kaniko/executor -f `pwd`/Dockerfile.test -c `pwd` -d=${ECR}/${APP_NAME}/test:latest ${KANIKO_OPTIONS}'
          }
        }
      }
    }
    stage('unit') {
      agent {
        kubernetes {
          inheritFrom 'default mysql'
          yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    image: ${ECR}/${APP_NAME}/test:latest
    imagePullPolicy: Always
    resources:
      requests:
        memory: 256Mi
    command:
    - cat
    tty: true
"""
        }
      }
      environment {
        COVERAGE = 'true'
        DISABLE_SPRING = 'true'
        FORMAT = 'junit'
        HEADLESS = 'true'
        RAILS_ENV = 'test'
      }
      steps {
        container('app') {
          ansiColor('xterm') {
            sh "bundle exec rake dad:db:create"
            sh "bundle exec rails db:reset"
            sh "bundle exec rails test"
          }
        }
      }
      post {
        always { publishUnitResult() }
      }
    }
    stage('e2e') {
      agent {
        kubernetes {
          inheritFrom 'default mysql chrome'
          yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    image: ${ECR}/${APP_NAME}/test:latest
    imagePullPolicy: Always
    resources:
      requests:
        memory: 256Mi
    command:
    - cat
    tty: true
"""
        }
      }
      environment {
        COVERAGE = 'true'
        DISABLE_SPRING = 'true'
        FORMAT = 'junit'
        HEADLESS = 'true'
        RAILS_ENV = 'test'
      }
      steps {
        container('app') {
          ansiColor('xterm') {
            sh "bundle exec rake dad:db:create"
            sh "bundle exec rails db:reset"
            sh 'bundle exec rake dad:test'
            sh 'bundle exec rake dad:test user_stories'
          }
        }
      }
      post {
        always { publishE2EResult() }
      }
    }
    stage('release') {
      agent { kubernetes { inheritFrom 'kaniko' } }
      environment {
        RELEASE_TAG = "v1.0.0-${BUILD_NUMBER}"
      }
      stages {
        stage('tagging') {
          steps {
            container('jnlp') {
              sshagent(credentials: [env.GITHUB_SSH_KEY]) {
                sh "git push origin HEAD:release"
                sh "git tag ${RELEASE_TAG}"
                sh "git push origin ${RELEASE_TAG}"
              }
            }
          }
        }
        stage('artifact') {
          steps {
            container('kaniko') {
              ansiColor('xterm') {
                sh '/kaniko/executor -f `pwd`/Dockerfile.app -c `pwd` -d=${ECR}/${APP_NAME}/app:${RELEASE_TAG} ${KANIKO_OPTIONS}'
              }
            }
          }
        }
      }
    }
  }
}

def publishUnitResult() {
  junit 'test/reports/**/*.xml'
  script { step([$class: 'RcovPublisher', reportDir: "coverage/rcov"]) }
}

def publishE2EResult() {
  publishHTML(target: [allowMissing: true, alwaysLinkToLastBuild: true, reportDir: 'features/reports', reportName: 'Features', reportFiles: 'index.html'])
  publishHTML(target: [allowMissing: true, alwaysLinkToLastBuild: true, reportDir: 'user_stories/reports', reportName: 'Features', reportFiles: 'index.html'])
}
