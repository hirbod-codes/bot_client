FROM nginx:1 AS web

COPY flutter_client/nginx/default.conf /etc/nginx/cond.f/default.conf

COPY flutter_client/build/web/ /web

EXPOSE 80 443
