# Use Alpine Linux as the base image
FROM nodered/node-red:3.1.11-18

USER root

RUN apk add --no-cache bash

WORKDIR /usr/src/node-red


COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN chown -R node-red:node-red /start.sh
# Install necessary programs and npm packages
RUN apk add --no-cache tini && \
    npm install -g npm@latest && \
    npm cache clean --force

RUN npm install cors bcrypt

COPY settings.js /settings.js
RUN chmod +x /settings.js
RUN chown -R node-red:node-red /settings.js

RUN chown -R node-red:node-red /usr/src/node-red

RUN chown -R node-red:node-red /data
RUN chmod 777 /data
# Start Node-RED with Tini to handle proper process termination
ENTRYPOINT ["/sbin/tini", "--"]
# Expose port
EXPOSE 10000
USER node-red
CMD ["/bin/bash", "-c", "/start.sh"]
