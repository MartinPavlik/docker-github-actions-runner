#!/usr/bin/env bash

GITHUB_REPOSITORY="$1"
GITHUB_TOKEN="$2"
GITHUB_SHA="$3"

docker run -d \
	  -e GITHUB_REPOSITORY="https://github.com/$GITHUB_REPOSITORY" \
	  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
	  -e RUNNER_NAME="Test-$GITHUB_SHA" \
	  -e REPLACE_EXISTING_RUNNER="true" \
	  --name testimage \
	  image

while true; do
	if [ ! -z "$(docker exec testimage bash -c 'cat /app/started')" ]; then
		break
	fi
done
docker logs testimage > .testlogs

# TEST: Should connect to GitHub
if [ -z "$(cat .testlogs | grep 'Connected to GitHub')" ]; then
	echo "TEST FAILED: Should connect to GitHub"
	exit 1
else
	echo "TEST PASSED: Should connect to GitHub"
fi

# TEST: Should not ask for runner name
if [ ! -z "$(cat .testlogs | grep 'Enter the name of runner')" ]; then
	echo "TEST FAILED: Should not ask for runner name"
	exit 1
else
	echo "TEST PASSED: Should not ask for runner name"
fi

# TEST: Should not ask for github repository
if [ ! -z "$(cat .testlogs | grep 'What is the URL of your repository')" ]; then
	echo "TEST FAILED: Should not ask for github repository"
	exit 1
else
	echo "TEST PASSED: Should not ask for github repository"
fi

# TEST: Should not ask for runner register token
if [ ! -z "$(cat .testlogs | grep 'Enter runner register token')" ]; then
	echo "TEST FAILED: Should not ask for runner register token"
	exit 1
else
	echo "TEST PASSED: Should not ask for runner register token"
fi

# TEST: Should add runner
if [ -z "$(cat .testlogs | grep 'Runner successfully added')" ]; then
	echo "TEST FAILED: Should add runner"
	exit 1
else
	echo "TEST PASSED: Should add runner"
fi

# TEST: Should establish connection
if [ -z "$(cat .testlogs | grep 'Runner connection is good')" ]; then
	echo "TEST FAILED: Should establish connection"
	exit 1
else
	echo "TEST PASSED: Should establish connection"
fi

# Kill test container
docker kill testimage && docker rm testimage