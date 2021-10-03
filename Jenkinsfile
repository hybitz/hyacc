pipeline {
  agent { label 'master' }
  environment {
      COVERAGE = 'true'
      EXPAND = 'false'
      FORMAT = 'junit'
  }
  stages {
    stage('test') {
      steps {
        test()
      }
      post {
        always { publish() }
        success { sh 'git push origin HEAD:release' }
      }
    }
  }
}

def test() {
  ansiColor('xterm') {
    sh 'bundle install --quiet'
    sh 'yarn install'
    sh 'bundle exec rails log:clear'
    sh 'bundle exec rails tmp:cache:clear'
    sh 'bundle exec rake dad:setup:test'
    sh 'bundle exec rails db:schema:load'
    sh 'rm -Rf coverage'
    sh 'bundle exec rails test'
    sh 'bundle exec rake dad:test'
    sh 'bundle exec rake dad:test user_stories'
  }
}

def publish() {
  junit 'test/reports/**/*.xml'
  script {
    step([$class: 'RcovPublisher', reportDir: "coverage/rcov"])
  }
}
