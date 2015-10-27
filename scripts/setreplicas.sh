#!/bin/sh

THISHOST=$(hostname)
basedir="../mongodb"
replicasetname="MASTERCLASS"
port0="30000"
port1="30001"
port2="30002"
rep0="$THISHOST:$port0"
rep1="$THISHOST:$port1"
rep2="$THISHOST:$port2"

echo "Creating the folder structure for replicaset"
mkdir -p $basedir/replica
mkdir -p $basedir/replica/0
mkdir -p $basedir/replica/1
mkdir -p $basedir/replica/2

echo "Launch mongod's"
mongod --dbpath $basedir/replica/0 --fork --logpath $basedir/replica/0/log --port $port0 --replSet $replicasetname
mongod --dbpath $basedir/replica/1 --fork --logpath $basedir/replica/1/log --port $port1 --replSet $replicasetname
mongod --dbpath $basedir/replica/2 --fork --logpath $basedir/replica/2/log --port $port2 --replSet $replicasetname

echo "Configure replica set"
conf="{'_id':'$replicasetname', 'members':[ {'_id': 0, 'host': '$rep0'}, {'_id': 1, 'host': '$rep1'}, {'_id': 2, 'host': '$rep2'}]}"
echo $conf
mongo --host $rep0 --eval "rs.initiate($conf)"

sleep 2

echo "Import data into replicaset"
echo mongoimport --type csv --headerline --host $rep0,$rep1,$rep2 -d laliga -c results ../dataset/SP1.csv
