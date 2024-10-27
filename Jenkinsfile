pipeline {
  agent none
  environment {
    KANIKO_OPTIONS = "--cache=${CACHE} --compressed-caching=false --build-arg registry=${ECR}"
  }
  stages {
    stage('build') {
      agent { kubernetes { inheritFrom 'default' } }
      steps {
        container('kaniko') {
          ansiColor('xterm') {
            sh '/kaniko/executor -f `pwd`/Dockerfile.base -c `pwd` -d=${ECR}/hyacc/base:latest ${KANIKO_OPTIONS}'
            sh '/kaniko/executor -f `pwd`/Dockerfile.test -c `pwd` -d=${ECR}/hyacc/test:latest ${KANIKO_OPTIONS}'
          }
        }
      }
    }
    stage('test') {
      agent {
        kubernetes {
          yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: hyacc
    image: ${ECR}/hyacc/test:latest
    imagePullPolicy: Always
    resources:
      requests:
        memory: 1500Mi
    command:
    - cat
    tty: true
  - name: mysql
    image: mysql:5.7
    env:
    - name: MYSQL_ALLOW_EMPTY_PASSWORD
      value: yes
    - name: MYSQL_DATABASE
      value: hyacc_test
    - name: MYSQL_USER
      value: hyacc
    - name: MYSQL_PASSWORD
      value: hyacc
"""
        }
      }
      environment {
        COVERAGE = 'true'
        FORMAT = 'junit'
        RAILS_ENV = 'test'
      }
      steps {
        container('mysql') {
          sh """
while ! mysqladmin ping --user=root -h 127.0.0.1 --port=3306 --silent; do
    sleep 1
done
"""
        }
        container('hyacc') {
          ansiColor('xterm') {
            sh "bundle exec rails db:reset"
            sh "bundle exec rails test"
            sh 'bundle exec rake dad:test'
            sh 'bundle exec rake dad:test user_stories'
          }
        }
      }
      post {
        always { publish() }
      }
    }
    stage('release') {
      agent { kubernetes { inheritFrom 'default' } }
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
                sh '/kaniko/executor -f `pwd`/Dockerfile.app -c `pwd` -d=${ECR}/hyacc/app:${RELEASE_TAG} ${KANIKO_OPTIONS}'
              }
            }
          }
        }
      }
    }
  }
}

def publish() {
  junit 'test/reports/**/*.xml'
  script {
    step([$class: 'RcovPublisher', reportDir: "coverage/rcov"])
  }
}
