##############################################################
# Makefile for Chatbot db
##############################################################

# Build vars
DOCKER_NAME=chatbot-db
DOCKER_TAG=latest
DOCKER_IMG=$(DOCKER_NAME):$(DOCKER_TAG)
REMOTE_IMG:=docker.io/umgccaps/$(DOCKER_IMG)
BUILD_IMG=docker.io/umgccaps/advance-development-factory:latest

BUILD_ARGS=--build-arg MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD)

URL=municipal-permit-chabot-db-test-again

# PHONY
.PHONY: all start clear push help

####################################################################
#	make all:
#		This builds the mysql Docker image.
#
####################################################################
all:
	docker build -f ./docker/Dockerfile $(BUILD_ARGS) -t $(DOCKER_IMG) .

####################################################################
#	make start:
#		This starts the mysql docker image. 
#
####################################################################
start:
	docker run -p 3306:3306 --rm -d --name mysql $(DOCKER_IMG)

####################################################################
#	make stop:
#		This stops the mysql docker image. 
#
####################################################################
stop:
	docker stop mysql
	
####################################################################
#	make push:
#		This pushes the Docker image to $(REMOTE_IMG)
#
####################################################################
push:
	docker tag $(DOCKER_IMG) $(REMOTE_IMG)
	docker push $(REMOTE_IMG)


deploy:
	docker run -v $(PWD)/:/repo --entrypoint '/bin/bash' $(BUILD_IMG) \
		-c 'cd /repo && az login && az group create --name devTestGroup --location eastus && \
			az deployment group create --resource-group devTestGroup \
			--template-file azure/template.json \
			--parameter azure/parameters.json \
			--parameter imageName=$(REMOTE_IMG) \
			--parameter dnsNameLabel=$(URL)'
	@$(info $(REMOTE_IMG) deployed to $(URL).eastus.azurecontainer.io)
	@$(info This may take a few minutes to respond)


##############################################################
#	make stop-deploy:
#		This stops the Azure container instances.
#
##############################################################
stop-deploy:
	docker run -v $(PWD)/:/repo --entrypoint '/bin/bash' $(BUILD_IMG) \
		-c 'cd /repo && az login && az group delete --name devTestGroup --yes'


# This prints make commands and usage
help:
	@$(info cahtbot db)
	@$(info Prerequisites: )
	@$(info 1. GNU BASH version 4.2.46+)
	@$(info 2. GNU Make version 3.82+)
	@$(info 3. Docker version 19.03.12+)
	@$(info -----------------------------------------------------------------------------------------------------------)
	@cat Makefile | sed -n -e '/####/,/#####/ p' | grep -v '###' | sed -e 's/#//g' | grep -v Makefile|grep -v help
