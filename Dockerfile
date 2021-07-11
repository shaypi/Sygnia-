FROM alpine:3.14.0

RUN apk add --no-cache wget build-base openssl openssl-dev zlib-dev linux-headers pcre-dev ffmpeg ffmpeg-dev

ARG NGINX_VERSION=1.21.1

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
RUN tar -xzvf nginx-${NGINX_VERSION}.tar.gz

RUN set -x \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

RUN cd  /nginx-${NGINX_VERSION} \
  && ./configure \
    --user=nginx \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --group=nginx \
    --with-http_ssl_module \
  && make \
  && make install

RUN echo "daemon off;" >> /usr/local/nginx/conf/nginx.conf
ENV PATH /usr/local/nginx/sbin:$PATH

#-----------------------------------------------------------------------------------------------------------------------------------#

FROM nginx:stable-alpine

COPY nginx.conf /usr/local/nginx/conf/nginx.conf

ENV PATH /usr/local/nginx/sbin:$PATH

COPY --from=0 /usr/local/nginx/sbin/nginx /usr/sbin/nginx

RUN     chown -R nginx:nginx /var/cache && \
        chown -R nginx:nginx /var/log/nginx && \
	chown -R nginx:nginx /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
       chown -R nginx:nginx /var/run/nginx.pid

EXPOSE 443 80

USER nginx

ENTRYPOINT  ["/usr/sbin/nginx"]
