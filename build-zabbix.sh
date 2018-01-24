#!/bin/bash

function install_dependency() {
	yum -y install \
		curl \
		libcurl-devel \
		net-snmp \
		net-snmp-devel \
		perl-DBI \
		libdbi-dbd-mysql \
		mysql-devel \
		gcc g++ \
		make \
		libxml2 libxml2-devel \
		libevent-devel > /dev/null
}

function add_zabbix_user() {
	if grep zabbix /etc/passwd > /dev/null 2>&1; then
		echo "zabbix user alread exist"
		return
	fi

	groupadd zabbix
	useradd -g zabbix -s /sbin/nologin zabbix
}

function zabbix_server_installed() {
	[ -f /usr/local/zabbix-server/sbin/zabbix_server ]
}

function build_zabbix_server() {
	if zabbix_server_installed; then
		echo "zabbix already installed"
		return
	fi

	if [ ! -d zabbix-3.4.4 ]; then
		if [ ! -f zabbix-3.4.4.tar.gz ]; then
			wget http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.4.4/zabbix-3.4.4.tar.gz/download
			mv download zabbix-3.4.4.tar.gz
		fi

		tar xf zabbix-3.4.4.tar.gz
	fi
	pushd zabbix-3.4.4
	./configure --prefix=/usr/local/zabbix-server --enable-server --with-mysql --with-net-snmp --with-libcurl --with-libxml2 --enable-agent --enable-ipv6
	make && make install
	popd
}

install_dependency
add_zabbix_user
build_zabbix_server
