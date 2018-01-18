#!/bin/sh

# correctly pass arguments on another shell in docker
# https://stackoverflow.com/a/42588600
if [ "$#" -lt 1 ]; then
  quoted_args=""
else
  quoted_args="$(printf " %q" "${@}")"
fi

docker-compose exec php \
  /bin/ash -c "cd /usr/share/nginx/html && ./bin/console ${quoted_args}"
