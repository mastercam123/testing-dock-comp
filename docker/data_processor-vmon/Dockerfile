FROM node:16-alpine3.16 as builder

WORKDIR /app

COPY package.json package-lock.json customized_module.ts custom.SMV.ts cs_custom_processor.js tsconfig.json ./

RUN npm install --development
RUN npm run build




FROM node:16-alpine3.16

#ARG NODE_ENV
#ENV NODE_ENV $NODE_ENV


WORKDIR /app

COPY --from=builder /dist /app
COPY package.json package-lock.json /app/

RUN npm install 

CMD sh -c "cd /app && sleep 10 && npm run start"
