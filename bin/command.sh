#!/bin/sh

# pass arguments to another shell in docker (posix compatible)
# https://stackoverflow.com/a/8723305
C=''
for i in "$@"; do
    case "$i" in
        *\'*)
            i=`printf "%s" "$i" | sed "s/'/'\"'\"'/g"`
            ;;
        *) : ;;
    esac
    C="$C '$i'"
done
#printf "$0%s\n" "$C"

# run custom command in application folder
docker-compose exec php \
  /bin/ash -c "cd /usr/share/nginx/html && $C"
