
# 环境版本
FROM 1and1internet/ubuntu-16-nginx
# 直接默认非交互
ARG DEBIAN_FRONTEND=noninteractive
# php 环境的版本
ARG PHP_VERSION=7.2
# 设置时间环境变量
ENV TZ "Asia/Shanghai"

# 生成的文件存放在files
COPY files /
RUN apt-get update
RUN \
    apt-get update && \
    apt-get install -y software-properties-common python-software-properties && \
    add-apt-repository -y -u ppa:ondrej/php && \
    apt-get update
# 按照php 的扩展
RUN apt-get install -y imagemagick graphicsmagick && \
    apt-get install -y php${PHP_VERSION}-bcmath \
                        php${PHP_VERSION}-bz2 \
                        php${PHP_VERSION}-cli \
                        php${PHP_VERSION}-common \
                        php${PHP_VERSION}-curl \
                        php${PHP_VERSION}-dba \
                        php${PHP_VERSION}-fpm \
                        php${PHP_VERSION}-gd \
                        php${PHP_VERSION}-gmp \
                        php${PHP_VERSION}-imap \
                        php${PHP_VERSION}-intl \
                        php${PHP_VERSION}-ldap \
                        php${PHP_VERSION}-mbstring \
                        php${PHP_VERSION}-mysql \
                        php${PHP_VERSION}-odbc \
                        php${PHP_VERSION}-pgsql \
                        php${PHP_VERSION}-recode \
                        php${PHP_VERSION}-snmp \
                        php${PHP_VERSION}-soap \
                        php${PHP_VERSION}-sqlite \
                        php${PHP_VERSION}-tidy \
                        php${PHP_VERSION}-xml \
                        php${PHP_VERSION}-xmlrpc \
                        php${PHP_VERSION}-xsl \
                        php${PHP_VERSION}-zip \
                        php${PHP_VERSION}-imagick \
                        php${PHP_VERSION}-dev && \
    apt-get install -y php-gnupg php-mongodb php-redis php-streams php-fxsl
RUN apt-get install -y git curl wget zlib1g-dev pkg-config libz-dev libnghttp2-dev build-essential libexpat1-dev libgeoip-dev libpng-dev libpcre3-dev libssl-dev libxml2-dev rcs libmcrypt-dev libcurl4-openssl-dev libjpeg-dev libwebp-dev openssl 
# 安装composer
RUN  mkdir /tmp/composer/ && \
    cd /tmp/composer && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod a+x /usr/local/bin/composer && \
    cd / && \
    rm -rf /tmp/composer


# 安装kafka
RUN git clone https://github.com/edenhill/librdkafka.git \
    && cd librdkafka \
    && ./configure \
    && make \
    && make install

# 安装驱动
RUN pecl install http://pecl.php.net/get/mongodb-1.4.4.tgz \
    && echo "extension=mongodb.so" >> /etc/php/${PHP_VERSION}/fpm/conf.d/20-mongodb.ini \
    && pecl install http://pecl.php.net/get/yac-2.0.2.tgz \
    && echo "extension=yac.so" >> /etc/php/${PHP_VERSION}/fpm/conf.d/20-yac.ini \
    && pecl install http://pecl.php.net/get/grpc-1.10.0.tgz \
    && echo "extension=grpc.so" >> /etc/php/${PHP_VERSION}/fpm/conf.d/20-grpc.ini \
    && pecl install http://pecl.php.net/get/protobuf-3.5.1.1.tgz \
    && echo "extension=protobuf.so" >> /etc/php/${PHP_VERSION}/fpm/conf.d/20-protobuf.ini \
    && pecl install http://pecl.php.net/get/rdkafka-3.0.5.tgz \
    && echo "extension=rdkafka.so" >> /etc/php/${PHP_VERSION}/fpm/conf.d/20-rdkafka.ini \
    && pecl install http://pecl.php.net/get/redis-5.3.4.tgz \
    && echo "extension=redis.so" >> /etc/php/${PHP_VERSION}/fpm/conf.d/20-redis.ini \
    && pecl install http://pecl.php.net/get/swoole-4.6.5.tgz \
    && echo "extension=swoole.so" >> /etc/php/${PHP_VERSION}/fpm/conf.d/20-swoole.ini

# 执行移除等操作
RUN  apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /etc/nginx/sites-enabled/default /etc/nginx/sites-available/* && \
    sed -i -e 's/^user = www-data$/;user = www-data/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i -e 's/^group = www-data$/;group = www-data/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i -e 's/^listen.owner = www-data$/;listen.owner = www-data/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i -e 's/^listen.group = www-data$/;listen.group = www-data/g' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf && \
    sed -i -e 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i -e 's/post_max_size = 8M/post_max_size = 512M/g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i -e 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/${PHP_VERSION}/fpm/php.ini && \
    sed -i -e 's/fastcgi_param  SERVER_PORT        $server_port;/fastcgi_param  SERVER_PORT        $http_x_forwarded_port;/g' /etc/nginx/fastcgi.conf && \
    sed -i -e 's/fastcgi_param  SERVER_PORT        $server_port;/fastcgi_param  SERVER_PORT        $http_x_forwarded_port;/g' /etc/nginx/fastcgi_params && \
    sed -i -e '/sendfile on;/a\        fastcgi_read_timeout 300\;' /etc/nginx/nginx.conf && \
	sed -i -e 's/^session.gc_probability = 0/session.gc_probability = 1/' \
		   -e 's/^session.gc_divisor = 1000/session.gc_divisor = 100/' /etc/php/${PHP_VERSION}/*/php.ini && \
    mkdir -p /usr/src/tmp/ioncube && \
    curl -fSL "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz" -o /usr/src/tmp/ioncube_loaders_lin_x86-64.tar.gz && \
    tar xfz /usr/src/tmp/ioncube_loaders_lin_x86-64.tar.gz -C /usr/src/tmp/ioncube && \
    cp /usr/src/tmp/ioncube/ioncube/ioncube_loader_lin_${PHP_VERSION}.so /usr/lib/php/20170718/ && \
    rm -rf /usr/src/tmp/ && \
    mkdir --mode 777 /var/run/php && \
    chmod 755 /hooks /var/www && \
    chmod -R 777 /var/www/ /var/log && \
    sed -i -e 's/index index.html/index index.php index.html/g' /etc/nginx/sites-enabled/site.conf && \
    chmod 666 /etc/nginx/sites-enabled/site.conf && \
    nginx -t && \
    mkdir -p /run /var/lib/nginx /var/lib/php && \
    chmod -R 777 /run /var/lib/nginx /var/lib/php /etc/php/${PHP_VERSION}/fpm/php.ini /etc/nginx/sites-enabled/*

# COPY --from=ioncube_loader /ioncube/ioncube_loader_lin_${PHP_VERSION}.so /usr/lib/php/20170718/