FROM alpine:3.16

ARG MONGODB_HOSTNAME
ENV MONGODB_HOSTNAME=$MONGODB_HOSTNAME
ARG JSON_SCADA_MONGODB_NAME
ENV JSON_SCADA_MONGODB_NAME=$JSON_SCADA_MONGODB_NAME
ARG JSON_SCADA_NODE_NAME
ENV JSON_SCADA_NODE_NAME=$JSON_SCADA_NODE_NAME

# Comment
RUN [ "sh", "-c", "echo we are running some cool things!" ]
RUN [ "sh", "-c", "echo This is mongodb hostname: $MONGODB_HOSTNAME" ]
RUN [ "sh", "-c", "echo This is json scada mongodb: $JSON_SCADA_MONGODB_NAME" ]
RUN [ "sh", "-c", "echo This is json node name: $JSON_SCADA_NODE_NAME" ]