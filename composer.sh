#!/bin/sh

# dedicated composer container for executing composer commands [https://hub.docker.com/_/composer/]
#docker run --rm --interactive --tty --volume $PWD/www:/app --user $(id -u):$(id -g) composer $@


# correctly pass arguments on another shell in docker
# https://stackoverflow.com/a/42588600
if [ "$#" -lt 1 ]; then
  quoted_args=""
else
  quoted_args="$(printf " %q" "${@}")"
fi

# run composer in application folder
docker-compose exec php \
  /bin/ash -c "cd /usr/share/nginx/html && composer ${quoted_args}"
