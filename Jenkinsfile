node {

    stage("Git Clone"){

        git credentialsId: 'GIT_CREDENTIALS', url: 'https://github.com/shaypi/Sygnia-.git'
    }

    stage("Docker build"){
        sh 'docker version'
        sh 'docker build -t sygnia:1.0 -p 8080:8080 .'
        sh 'docker image list'
        sh 'docker tag sygnia:1.0 shaypi/sygnia:10'
    }

    withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD', variable: 'PASSWORD')]) {
        sh 'docker login -u shaypi -p $PASSWORD'
    }

    stage("Push Image to Docker Hub"){
        sh 'docker push  shaypi/sygnia:10'
    }

    stage("SSH Into k8s Server") {
        def remote = [:]
        remote.name = 'Master'
        remote.host = '10.100.102.20'
        remote.user = 'shay'
        remote.password = 'ZAQ!1qaz'
        remote.allowAnyHosts = true

        stage('Deploying liveness-readiness') {
            sshPut remote: remote, from: 'liveness-readiness.yaml', into: '.'
            sshPut remote: remote, from: 'nginx-svc.yaml', into: '.'
        }

        stage('Deploying my task') {
          sshCommand remote: remote, command: "kubectl apply -f liveness-readiness.yaml"
          sshCommand remote: remote, command: "kubectl apply -f nginx-svc.yaml"
        }
    }

}
