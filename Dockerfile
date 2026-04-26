FROM node:20-alpine
WORKDIR /opt
COPY . /opt
RUN npm install
ENTRYPOINT ["npm", "run", "start"]