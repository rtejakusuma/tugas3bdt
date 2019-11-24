sudo cp /vagrant/sources/hosts /etc/hosts
sudo cp '/vagrant/sources/sources.list' '/etc/apt/'

sudo apt update -y

sudo apt-get install redis -y

sudo cp /vagrant/conf/redis2.conf /etc/redis/redis.conf
sudo cp /vagrant/conf/sentinel2.conf /etc/redis-sentinel.conf
