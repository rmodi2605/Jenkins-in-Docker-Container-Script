#! /bin/bash

# Check Internet Connection >> Install Docker 
# Create Jenkins Docker Container

if [[ $(ping 1.1.1.1 -c 5  | grep time) != *"100% packet loss"* ]] ;
then
    sudo apt update -y
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    create_jenkins_container 
else 
    echo -e "Please Check Internet Connection"
fi


function create_jenkins_container  () {
    docker_service=$(sudo systemctl is-active docker.service)
    if [[ $docker_service != inactive ]] ;
    then
        sudo docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_volume:/var/jenkins_home --name jenkins jenkins/jenkins:lts
        sleep 30s
        jenkins_passwd=$(sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
        echo -e "\nJenkins url : http://localhost:8080 \n"
        echo -e "\nJenkins Password : $jenkins_passwd \n"
    else
        echo -e "Docker Service is NOT Running !"
    fi
}
