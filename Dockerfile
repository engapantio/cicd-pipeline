FROM node:20-alpine AS builder
WORKDIR /opt
COPY . /opt
RUN npm install
RUN npm run build


FROM node:20-alpine
WORKDIR /opt
COPY package*.json /opt/
RUN npm install --production
COPY --from=builder /opt/build /opt/build
ENTRYPOINT ["npm", "run", "start"]
