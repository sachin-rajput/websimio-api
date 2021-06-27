FROM centos:7

LABEL Maintainer="Sachin Rajput <sachin.rajput@dowjones.com>"
LABEL Description="Base CentOS OpenSSH server image"
LABEL CentOS="7"
LABEL Name="CentOS Nginx NodeJS"
LABEL VERSION="1"

#Update Software Repository
RUN yum -y install epel-release
RUN yum -y update
RUN yum -y install nginx
RUN yum -y install which

RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 14.13.0

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash  

SHELL ["/bin/bash", "--login", "-c"]

RUN	. $NVM_DIR/nvm.sh \
	&& nvm alias default $NODE_VERSION \
	&& nvm use default

ENV NODE_PATH "$NVM_DIR/v$NODE_VERSION/lib/node_modules"
ENV PATH "$PATH:$NVM_DIR/v$NODE_VERSION/bin"
RUN echo "export PATH=$NVM_DIR/v$NODE_VERSION/bin:${PATH}" >> /root/.bashrc

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install node.js
RUN npm install -g pm2 

#Updating the Timezone to New_York
RUN ln -snf /usr/share/zoneinfo/America/New_York /etc/localtime && echo America/New_York > /etc/timezone

# ------- API Project Set up ----------- #

# Create API project
RUN mkdir -p /apps/api/

# Copy API project
COPY ${PWD}/src/api /apps/api

WORKDIR /apps/api/

# RUN yarn global add serve

# install api code
RUN npm install

# ------- API Project Set up Complete ----------- #

RUN mkdir -p /apps/scripts/
COPY scripts /apps/scripts
RUN \
	ln -s /apps/scripts/start-nginx-node /usr/local/bin/start-nginx-node && \
	chmod +x /apps/scripts/start-nginx-node 

WORKDIR /apps/api

# Copy Nginx files
COPY nginx/default.conf /etc/nginx/conf.d/
COPY nginx/nginx.conf /etc/nginx/

RUN \
	ln -s /usr/local/nvm/versions/node/v$NODE_VERSION/bin/node /usr/bin/node

EXPOSE 443
EXPOSE 80
CMD ["start-nginx-node"]