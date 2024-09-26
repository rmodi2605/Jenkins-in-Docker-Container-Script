#! /bin/bash

function install_docker () {
    sudo apt update -y
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin bash-completion
    sudo curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker
    source ~/.bashrc
    sudo  systemctl start docker.service
}


function create_jenkins_container  () {
    docker_service=$(sudo systemctl is-active docker.service)
    if [[ $docker_service != inactive ]] ;
    then
        sudo docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_volume:/var/jenkins_home --name jenkins jenkins/jenkins:lts
        sleep 5s
        echo -e "\nJenkins Container Created \U1F44D\n"
        sleep 5s
    else
        echo -e "\n\033[31mDocker Service is NOT running\033[0m\n"
        exit 1
    fi
}


function verify_jenkins_container () {
    jenkins_container_status=$(sudo docker ps | grep jenkins | egrep -o "Up")
    if [[ $jenkins_container_status == Up ]] ;
    then
        jenkins_passwd=$(sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
        echo -e "\n\U1F517 Jenkins url : http://localhost:8080/ "
        echo -e "\n\U1F464 Jenkins Username : admin "
        echo -e "\n\U1F511 Jenkins Password : $jenkins_passwd "
        echo -e "\n\U1F4BE Jenkins Persistent Volume Storage Path on Host : /var/lib/docker/volumes/jenkins_volume/ "
        echo -e "\n\U1F4BD Jenkins Volume Mount Path on Container : /var/jenkins_home/ \n"
    else
        echo -e "\n\033[31mJenkins Container is NOT running\033[0m\n"
    fi
}


# Check Internet Connection  >>  Install Docker
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo -e "\n\U1F310 Checking Internet Connection . . . \n"
check_internet=$(ping 1.1.1.1 -c 5  | grep time)
if [[ $check_internet != *"100% packet loss"* ]] ;
then
    echo -e "\nInternet is Working Fine \U1F44D\n"
    echo -e "\n\U2795 Trying to Install Docker . . . \n"
    install_docker
else 
    echo -e "\n\033[31mPlease Check Internet Connection \U1F615 \033[0m\n"
    exit 1
fi


# Create Jenkins Container  >>  Verify and Get Detail for Access Jenkins container
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
check_docker_pkg=$(docker --version | awk '{print $1}')
if [[ $check_docker_pkg == Docker ]] ;
then
    echo -e "\nDocker Installed Successfully \U1F44D\n"
    echo -e "\n\U2795 Creating Jenkins Container . . . \n"
    create_jenkins_container
    sleep 5s
    echo -e "\n\U1F50D Getting Jenkins Container Details . . . \n"
    verify_jenkins_container
else
    echo -e "\n\033[31mDocker Installation Failed\033[0m\n"
    exit 1
fi
