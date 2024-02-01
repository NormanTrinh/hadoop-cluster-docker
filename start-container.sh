#!/bin/bash

# Create network if not exists
docker network inspect hadoop >/dev/null 2>&1 || \
    docker network create --driver bridge hadoop

# the default node number is 3
N=${1:-3}

# resize cluster by number of nodes
bash resize-cluster.sh $N

# start hadoop master container
docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
docker run -itd \
		--net=hadoop \
		-p 9870:9870 \
		-p 8088:8088 \
		--name hadoop-master \
		--hostname hadoop-master \
		danchoi2001/hadoop:1.0 &> /dev/null


# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	docker run -itd \
			--net=hadoop \
			--name hadoop-slave$i \
			--hostname hadoop-slave$i \
			danchoi2001/hadoop:1.0 &> /dev/null
	i=$(( $i + 1 ))
done 

# get into hadoop master container
docker exec -it hadoop-master bash
