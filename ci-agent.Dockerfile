FROM docker:27-cli AS docker-cli

FROM node:16

COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker

USER node
