FROM node:16-alpine3.16

#ARG NODE_ENV
#ENV NODE_ENV $NODE_ENV


WORKDIR /app

COPY ./ ./

RUN npm install 

CMD sh -c "cd /app && sleep 10 && node cs_data_processor.js"
