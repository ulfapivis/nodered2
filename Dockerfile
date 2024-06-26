# Use Alpine Linux as the base image
FROM nodered/node-red:3.1.11-18

USER root

RUN apk add --no-cache bash
# Set environment variables for Node-RED plugins
# These should be set in the Render dashboard
# ENV CUSTOM_NODES=${CUSTOM_NODES}
# ENV NODE_RED_USERNAME=${NODE_RED_USERNAME}
# ENV NODE_RED_PASSWORD=${NODE_RED_PASSWORD}
# ENV NODE_RED_CREDENTIAL_SECRET=${NODE_RED_CREDENTIAL_SECRET}
# ENV ALLOWED_IPS=${ALLOWED_IPS}
# ENV NODE_RED_FLOW=${NODE_RED_FLOW}
# ENV NODE_RED_FLOW_CRED=${NODE_RED_FLOW_CRED}
WORKDIR /usr/src/node-red
# # Copy the settings.js file into the container

#COPY custom_nodes.sh /data/custom_nodes.sh
#RUN chmod +x /data/custom_nodes.sh

COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN chown -R node-red:node-red /start.sh
# Install necessary programs and npm packages
RUN apk add --no-cache tini && \
    npm install -g npm@latest && \
    npm cache clean --force


# Set up the Express server as a reverse proxy
#COPY express-proxy-server.js /express-proxy-server.js
#RUN npm install express http-proxy-middleware helmet cors bcrypt
RUN npm install cors bcrypt

COPY settings.js /settings.js
RUN chmod +x /settings.js
RUN chown -R node-red:node-red /settings.js

COPY settings_noip.js /settings_noip.js
RUN chmod +x /settings_noip.js
RUN chown -R node-red:node-red /settings_noip.js

RUN chown -R node-red:node-red /usr/src/node-red
RUN chmod 644 /usr/src/node-red
RUN chown -R node-red:node-red /data
RUN chmod 777 /data
# Start Node-RED with Tini to handle proper process termination
ENTRYPOINT ["/sbin/tini", "--"]
# Expose port
EXPOSE 10000
USER node-red
CMD ["/bin/bash", "-c", "/start.sh"]
