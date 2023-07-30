# 使用Ubuntu 22.04镜像作为基础镜像
FROM ubuntu:22.04

ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive \
    ROOT_PATH=/nexusphp
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新包列表并安装Nginx和PHP及相关扩展

# ubuntu2004, php7.4
# RUN apt-get update \
#     && DEBIAN_FRONTEND=noninteractive apt-get install -y nginx php php-fpm php-bcmath \
#     php-curl php-gd php-gettext php-gmp php-imagick php-intl php-json php-mbstring \
#     php-mysql php-opcache php-pdo php-redis php-soap php-sockets php-sqlite3 php-xml php-zip \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# ubuntu2224, php8.2
# php modules
RUN apt-get update \
    && apt-get install -y php php-fpm php-bcmath php-mbstring php-zip \
    php-curl php-gd php-php-gettext php-gmp php-imagick php-intl php-json \
    php-mysql php-opcache php-pdo php-redis php-soap php-sockets php-sqlite3 php-xml \
    composer

# others
RUN apt-get purge -y apache2 \
    && apt-get install -y nginx vim less telnet unzip jq ncdu lsof tree curl wget supervisor bcron \
    && sed -i 's/listen = \/run\/php\/php.*-fpm\.sock/listen = \/run\/php\/php-fpm.sock/g' \
    /etc/php/*/fpm/pool.d/www.conf

# RUN apt-get install -y curl wget
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && php -m && service --status-all
# RUN ln -s /run/php/php8.1-fpm.sock /run/php/php-fpm.sock

## FIXME: test
# RUN php -m

# 将Nginx配置文件复制到容器中
# COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# 将PHP-FPM配置文件复制到容器中
# COPY www.conf /etc/php/7.4/fpm/pool.d/www.conf

VOLUME [ "/var/log/nginx", "/nexusphp", "/etc/nginx/sites-enabled", \
         "/etc/nginx/conf.d", "/etc/supervisor", "/etc/php/8.1/fpm/pool.d" ]

WORKDIR /nexusphp

EXPOSE 8080 80 443

# 启动Nginx和PHP-FPM
# CMD service php-fpm start && nginx -g "daemon off;"
CMD service `service --status-all | grep php | grep fpm | awk '{print $NF}'` start && nginx -g "daemon off;"
