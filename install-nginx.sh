#!/bin/bash
# Script by Xfree
# Script Date: 26/11/2020
# Apply For: Centos 8
# Install nginx 1.19.1 PCRE 8.44, Zlib 1.2.11, openssl 1.1.1g
adduser nginx --system --no-create-home --shell /bin/false --user-group
#Install build tools
dnf groupinstall 'Development Tools' -y
dnf install epel-release -y
dnf install wget unzip -y
#Install Dependencies
dnf install perl perl-devel perl-ExtUtils-Embed libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel GeoIP GeoIP-devel gperftools-devel -y
#Uncompress Source
tar zxvf nginx-1.19.5.tar.gz
tar zxvf zlib-*
tar zxvf openssl-*
tar zxvf pcre-8.44.tar.gz
unzip echo-nginx-module.zip
unzip ngx_cache_purge.zip
unzip set-misc-nginx-module.zip
unzip headers-more-nginx-module.zip
unzip ngx_devel_kit.zip
unzip nginx-module-vts.zip
unzip ngx_log_if.zip
cd nginx-1.19.5
#start install
./configure \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--conf-path=/etc/nginx/nginx.conf \
--modules-path=/etc/nginx/modules \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--user=nginx \
--group=nginx \
--with-pcre=../pcre-8.44 \
--with-pcre-jit \
--with-zlib=../zlib-1.2.11 \
--with-openssl=../openssl-1.1.1g \
--with-http_ssl_module \
--with-http_v2_module \
--with-threads \
--with-file-aio \
--with-http_degradation_module \
--with-http_auth_request_module \
--with-http_geoip_module \
--with-http_realip_module \
--with-http_secure_link_module \
--with-cpp_test_module \
--with-debug \
--with-google_perftools_module \
--with-mail \
--with-mail_ssl_module \
--with-http_mp4_module \
--with-http_flv_module \
--with-stream \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-http_dav_module \
--with-http_image_filter_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_addition_module \
--with-http_random_index_module \
--with-http_slice_module \
--with-http_sub_module \
--with-http_xslt_module \
--with-select_module \
--with-poll_module \
--add-module=../ngx_devel_kit \
--add-module=../set-misc-nginx-module \
--add-module=../ngx_cache_purge \
--add-module=../headers-more-nginx-module \
--add-module=../echo-nginx-module \
--add-module=../nginx-module-vts \
--add-module=../ngx_log_if
make
make install

rm -f /etc/systemd/system/nginx.service
cat > "/etc/systemd/system/nginx.service" << END
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable nginx.service
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
