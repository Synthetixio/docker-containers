FROM nginx:1.23.3-alpine-slim

COPY nginx.conf /etc/nginx/nginx.conf

# trunk-ignore(hadolint/DL3018)
RUN apk add --no-cache \
    curl \
    wget \
    bind-tools \
    && echo "Finished installing packages"

RUN mkdir -p /etc/nginx/bots.d && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/globalblacklist.conf -O /etc/nginx/conf.d/globalblacklist.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/blockbots.conf -O /etc/nginx/bots.d/blockbots.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/ddos.conf -O /etc/nginx/bots.d/ddos.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/whitelist-ips.conf -O /etc/nginx/bots.d/whitelist-ips.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/whitelist-domains.conf -O /etc/nginx/bots.d/whitelist-domains.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/blacklist-user-agents.conf -O /etc/nginx/bots.d/blacklist-user-agents.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/custom-bad-referrers.conf -O /etc/nginx/bots.d/custom-bad-referrers.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/blacklist-ips.conf -O /etc/nginx/bots.d/blacklist-ips.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/bots.d/bad-referrer-words.conf -O /etc/nginx/bots.d/bad-referrer-words.conf && \
    wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/botblocker-nginx-settings.conf -O /etc/nginx/conf.d/botblocker-nginx-settings.conf

RUN sed -i 's/^\t*138.199.57.151\t*1;$/#\t138.199.57.151\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf && \
    sed -i 's/^\t*143.244.38.129\t*1;$/#\t143.244.38.129\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf && \
    sed -i 's/^\t*195.181.163.194\t*1;$/#\t195.181.163.194\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf && \
    sed -i 's/^\t*5.188.120.15\t*1;$/#\t5.188.120.15\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf && \
    sed -i 's/^\t*89.187.173.66\t*1;$/#\t89.187.173.66\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf

# copy nginx blocker update script into daily cron
COPY update_blocker.sh /etc/periodic/daily/update_blocker

# make sure script is executable
RUN chmod a+x /etc/periodic/daily/update_blocker

# start crond to update blocker
# trunk-ignore(hadolint/DL3059)
RUN crond -b
