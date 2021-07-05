#!/bin/bash

OUTPATH=/home/vagrant/out.log

dig @192.168.50.10 ns01.dns.lab >> $OUTPATH
dig @192.168.50.10 web1.dns.lab >> $OUTPATH
dig @192.168.50.10 web2.dns.lab >> $OUTPATH
dig @192.168.50.10 www.newdns.lab >> $OUTPATH

cat $OUTPATH
