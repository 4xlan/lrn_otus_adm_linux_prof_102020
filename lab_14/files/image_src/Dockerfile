FROM alpine:latest
WORKDIR /var/www/html/
EXPOSE 80
RUN apk update; apk upgrade ; apk add nginx; rm -r /var/cache/apk/*
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./page/ .
CMD ["/usr/sbin/nginx"]
