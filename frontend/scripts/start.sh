#!/bin/bash

# remove X-Forwarded-Proto for local 
if [[ "$APP_ENV" == "local" ]] ; then
 sed -i "s/return  301 https:\/\/\$host\$request_uri;//" /etc/nginx/sites-available/default.conf
fi

if [ -z "$WEBSITE_URL" ]; then
  echo "Please set WEBSITE_URL"
  exit 1
else
  sed -i "s#WEBSITE_URL#$WEBSITE_URL#g" /etc/nginx/sites-available/default.conf
fi

if [ ! -z "$PUID" ]; then
  if [ -z "$PGID" ]; then
    PGID=${PUID}
  fi
  deluser nginx
  addgroup -g ${PGID} nginx
  adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx -u ${PUID} nginx
else
  # Always chown webroot for better mounting
  chown -Rf nginx.nginx /srv/root/webroot
fi

# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
