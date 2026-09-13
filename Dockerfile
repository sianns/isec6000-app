FROM node:16

WORKDIR /usr/src/app

ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev

COPY app.js ./

EXPOSE 8080

USER node

CMD ["node", "app.js"]
