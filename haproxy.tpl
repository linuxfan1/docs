global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy18
    pidfile     /var/run/haproxy18.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy18/stats


defaults
    log                     global
    option                  dontlognull
    option http-server-close
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000


frontend wallet_mysql_rw
    bind *:3301
    mode tcp
    default_backend         wallet_mysql_master

backend wallet_mysql_master
    server db1 {{ key "mysql/wallet-mysql" }} check


frontend wallet_mysql_ro
    bind *:3302
    mode tcp
    default_backend         wallet_mysql_slave

backend wallet_mysql_slave
    balance leastconn
    server db1 172.18.0.198:3306 check
    server db2 172.18.2.199:3306 check




listen admin_status
    bind 0.0.0.0:8080
    mode http
    log 127.0.0.1 local3 err
    stats refresh 5s
    stats uri /admin?stats

