#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

install_ssr(){
	cd /opt
	echo 'SSR下载中...'
	git clone https://github.com/lelvoo/shadowsocksr-ssrpanel.git
	mv shadowsocksr-ssrpanel shadowsocksr
    	cd shadowsocksr
    	sh initcfg.sh
	echo '开始配置节点连接信息...'
	stty erase '^H' && read -p "数据库服务器地址:" mysqlserver
	stty erase '^H' && read -p "数据库名称:" database
	stty erase '^H' && read -p "数据库用户名:" username
	stty erase '^H' && read -p "数据库密码:" pwd
	stty erase '^H' && read -p "本节点ID:" nodeid
	stty erase '^H' && read -p "本节点流量计算比例:" ratio
	sed -i -e "s/db_host/$mysqlserver/g" usermysql.json
	sed -i -e "s/db_name/$database/g" usermysql.json
	sed -i -e "s/db_user/$username/g" usermysql.json
	sed -i -e "s/db_passwd/$pwd/g" usermysql.json
	sed -i -e "s/nodeID/$nodeid/g" usermysql.json
	sed -i -e "s/noderatio/$ratio/g" usermysql.json
	echo -e "配置完成!\n如果无法连上数据库，请检查本机防火墙或者数据库防火墙!\n请自行编辑user-config.json，配置节点加密方式、混淆、协议等"
    apt-get install python-pip -y
    pip install cymysql
    apt-get install supervisor -y
    echo "edit config"
    wget -N --no-check-certificate https://raw.githubusercontent.com/lelvoo/ssr-deploy/master/ssr.conf
    cp ssr.conf /etc/supervisor/conf.d/ssr.conf
    echo "ulimit -n 1024000">>/etc/default/supervisor
    /etc/init.d/supervisor restart
    supervisorctl restart ssr
    echo "supervisorctl tail -f ssr stderr"
    supervisorctl tail -f ssr stderr
}

open_bbr(){
	cd /opt
	wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/bbr.sh && chmod +x bbr.sh && bash bbr.sh
}

echo -e "1.Install SSR\n2.Open BBR"
stty erase '^H' && read -p "请输入数字进行安装[1-2]:" num
case "$num" in
	1)
	install_ssr
	;;
	2)
	open_bbr
	;;
	*)
	echo "请输入正确数字[1-2]:"
	;;
esac
