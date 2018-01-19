#!/bin/sh

# run composer in application folder
bin/command.sh composer "$@"

# dedicated composer container for executing composer commands [https://hub.docker.com/_/composer/]
#docker run --rm --interactive --tty --volume $PWD/www:/app --user $(id -u):$(id -g) composer $@
