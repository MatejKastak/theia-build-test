# Node version can be specified with `--build-arg <number>`
# Choose this version by default because theia restricts
# `node` engine to this version
# @ https://github.com/eclipse-theia/theia/blob/3bc2c2b9e48fcb0a6cba3a07bd121a8a16fa93fd/package.json#L7
ARG NODE_VERSION=12.18.3

# Choose buster because I am more familiar with debian than alpine
FROM node:${NODE_VERSION}-buster

# Install the build and container dependencies
RUN apt-get update \
    && apt-get install -y libx11-dev libxkbfile-dev

# Install dependencies for user environment such as:
# Install Python 3 from source
# Install latest stable CMake
# I will skip those, since they should not matter in this instance

# Create build directories
# - app :: this directory will contain the user app
# - theia :: this directory will contain the theia master
# * Maybe its not a good idea to put them directly into /home but it should
# matter in this instance
RUN mkdir -p /home/app \
	mkdir -p /home/theia \
    && mkdir -p /home/project


# === Build the theia modules from sources ===
WORKDIR /home/theia

# Basically clone the current master of theia repo
# It can be a bare `git clone ...` but I want to clone it to already created
# directory
# RUN git init \
# 	&& git remote add origin https://github.com/eclipse-theia/theia \
# 	&& git fetch origin master --depth 1 \
# 	&& git checkout master

# I am using modified sources of theia, with a commit on master that changes the
# problem widget label from "Problems" => "Success"
# see: https://github.com/MatejKastak/theia/commit/c0e4fb3600cfbd2203b8c488e813dd0d902493dd
RUN git init \
	&& git remote add origin https://github.com/MatejKastak/theia  \
	&& git fetch origin master --depth 1 \
	&& git checkout master

# Build the theia modules
RUN yarn

# Prepare the symlink
RUN yarn link


# === Build our custom app ===
WORKDIR /home/app

# Add our custom app description in `package.json`
ADD package.json /home/app/package.json

# Symlink the modules from theia build
RUN yarn link "@theia/monorepo"
# Install the theia-cli tool
RUN yarn
# Start the build via the installed tool
RUN yarn theia build
# Download the plugins specified in `package.json`
RUN yarn theia download:plugins

# I expect the plugins will be located @ `/home/app/plugins` but from the build
# log it looks like building theia master also downloads the plugins specified in
# https://github.com/eclipse-theia/theia/blob/master/package.json, so the plugins
# are duplicated
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/app/plugins

EXPOSE 3000

# Prepare the start command
ENTRYPOINT ["node", "/home/app/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0"]
# ENTRYPOINT ["sh", "-c", "cd /home/theia/examples/browser && yarn run start --hostname=0.0.0.0"]
# ENTRYPOINT ["yarn", "run", "start:browser",  "--hostname=0.0.0.0"]
# ENTRYPOINT ["yarn", "--cwd", "/home/theia/examples/browser", "run", "theia", "start", "--hostname=0.0.0.0"]
