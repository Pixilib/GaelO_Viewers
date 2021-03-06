# OHIF
FROM node:14.17 as ohif

RUN apt-get update -qy && \
    apt-get install -y --no-install-recommends apt-utils\
    git \
    python \
    make \
    g++

WORKDIR /ohif
RUN git clone --depth 1 --branch @ohif/viewer@4.12.9 https://github.com/OHIF/Viewers.git
RUN cd Viewers && yarn install && QUICK_BUILD=true PUBLIC_URL=/viewer-ohif/ yarn run build

# Stone
FROM alpine as stone
RUN apk --no-cache add wget
RUN apk add --update zip
RUN wget https://lsb.orthanc-server.com/stone-webviewer/2.2/wasm-binaries.zip
RUN mkdir /stone
RUN unzip wasm-binaries.zip -d /stone

# Nginx
FROM nginx:1.17-alpine

COPY nginx.config /etc/nginx/conf.d/default.conf

COPY --from=ohif /ohif/Viewers/platform/viewer/dist /usr/share/nginx/html/public/viewer-ohif/
COPY --from=stone /stone/wasm-binaries/StoneWebViewer /usr/share/nginx/html/public/viewer-stone/

COPY ./public/viewers/OHIF/app-config.js /usr/share/nginx/html/public/viewer-ohif/
COPY ./public/viewers/Stone/configuration.json /usr/share/nginx/html/public/viewer-stone/
