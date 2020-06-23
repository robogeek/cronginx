FROM nginx:stable

# Inspiration:
# https://hub.docker.com/r/gaafar/cron/

# Install cron, certbot, bash, plus any other dependencies

RUN apt-get update \
    && apt-get install -y cron bash wget certbot \
    && apt-get update -y \
    && mkdir -p /webroots /scripts \
    && rm -f /etc/nginx/conf.d/default.conf

COPY register.sh renew.sh /scripts/
RUN chmod +x /scripts/*.sh

# /webroots/DOMAIN.TLD/.well-known/... files go here
VOLUME /webroots
# This handles book-keeping files for Letsencrypt
VOLUME /etc/letsencrypt
# This lets folks inject Nginx config files
VOLUME /etc/nginx/conf.d

# Make the directories for the domains to manage
# /webroots/DOMAIN.TLD will be mounted 
# into each proxy as http://DOMAIN.TLD/.well-known

RUN mkdir -p /webroots/test.geekwisdom.net/.well-known/acme-challenge

WORKDIR /scripts

# This installs a Crontab entry which 
# runs "certbot renew" on several days a week at 03:22 AM

RUN echo "22 03 * * 2,7 root /usr/bin/certbot renew" >/etc/cron.d/certbot-renew

# RUN echo "22 03 * * 2,4,6,7 root /scripts/register.sh test.geekwisdom.net" >/etc/cron.d/certbot-test-geekwisdom-net


# Run both nginx and cron together
CMD [ "sh", "-c", "cron && nginx -g 'daemon off;'" ]
