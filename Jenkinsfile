pipeline {
    agent {
        label 'slave'
        
    }
    
    environment{
        registry1 = 'makmilord/terraform-pile'
        registry2 = 'makmilord/ansible-pile'
        registry3 = 'makmilord/restfull-webservice'
        registryCredential = 'dockerhub'
        dockerImage = ''
    }
    stages {
            stage('recuperation de l app') {
                steps{
                 git url : 'https://github.com/MoradMlik/Restful-Webservice.git'
            }
            }
            stage {
                failfast true
                parallel {
                     stage('build de l app') {
                       steps {
                                sh 'mvn clean package'
                                junit 'target/surefire-reports/*.xml' 
                        }
                }
            stage('recuperation de l image docker terraform et deploiement de l infra') {
                    steps {
                       script {
                        docker.withRegistry( registry1, registryCredential ) {
                            dockerImage.pull()
                        }
                    }
                    
                    script {
                        docker.run(registry1)
                    }
                    
                 }
            }
                    
             }
            }
           
        stage ('recuperation de l image Ansible et provisionnement de la pile') {
                steps {
                    script {
                        docker.withRegistry( registry2, registryCredential ) {
                            dockerImage.pull()
                        }
                    }
                    script {
                        docker.run(registry2)
                    }
                }
        
            }
            stage ('envoi de l image docker contenant le war sur le hub') {
                steps {
                   script {
                        docker.withRegistry( registry3, registryCredential ) {
                            dockerImage.push()
                        }
                    }
                }
        
            }
            stage ('deploiement TEST') {
                    when {
                        branch 'dev'
                    }
                    steps {
                        sh 'docker run -p 8000:8000 makmilord/restfull-webservice'
                    }
                    
                }
            stage ('deploiement PROD') {
                    when {
                        branch 'master'
                    }
                    steps {
                        sh 'docker run -p 8000:8000 makmilord/restfull-webservice'
                    }
                    
                }    
    }
}
 
