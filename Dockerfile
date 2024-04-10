FROM nginx:1 AS web

COPY flutter_client/build/web/ /usr/share/nginx/html

EXPOSE 80 443
