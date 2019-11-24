# Tugas 3 Basis Data Terdistribusi - Redis Cluster
Raden Teja Kusuma (5111640000012)

## Skema
## Spesifikasi
1. Redis Server:
    - `redis1`:
        - OS : `bento/ubuntu-18.04`
        - RAM : `512` MB
        - IP : `192.168.16.12`
    - `redis2`:
        - OS : `bento/ubuntu-18.04`
        - RAM : `512` MB
        - IP : `192.168.16.13`
    - `redis3`:
        - OS : `bento/ubuntu-18.04`
        - RAM : `512` MB
        - IP : `192.168.16.14`
2. Wordpress Server + MySQL:
    - `wordpress1`:
        - OS : `bento/ubuntu-18.04`
        - RAM : `512` MB
        - IP : `192.168.16.15`
    - `wordpress2`:
        - OS : `bento/ubuntu-18.04`
        - RAM : `512` MB
        - IP : `192.168.16.16`
## Konfigurasi Vagrant
1. `Vagrantfile`
```bash
Vagrant.configure("2") do |config|

  (1..3).each do |i|
    config.vm.define "redis#{i}" do |node|
      node.vm.hostname = "redis#{i}"
      node.vm.box = "bento/ubuntu-18.04"
      node.vm.network "private_network", ip: "192.168.16.#{11+i}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "redis#{i}"
        vb.gui = false
        vb.memory = "512"
      end

      node.vm.provision "shell", path: "sh/redis-#{i}.sh", privileged: false
    end
  end

  (1..2).each do |i|
    config.vm.define "wordpress#{i}" do |node|
      node.vm.hostname = "wordpress#{i}"
      node.vm.box = "bento/ubuntu-18.04"
      node.vm.network "private_network", ip: "192.168.16.#{14+i}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "wordpress#{i}"
        vb.gui = false
        vb.memory = "512"
      end

      node.vm.provision "shell", path: "sh/wordpress.sh", privileged: false
    end
  end

end
```
2. File Provision
    - `redis-1.sh`
    ```bash
    sudo cp /vagrant/sources/hosts /etc/hosts
    sudo cp '/vagrant/sources/sources.list' '/etc/apt/'

    sudo apt update -y

    sudo apt-get install redis -y

    sudo cp /vagrant/conf/redis1.conf /etc/redis/redis.conf
    sudo cp /vagrant/conf/sentinel1.conf /etc/redis-sentinel.conf
    ```
    - `redis-2.sh`
    ```bash
    sudo cp /vagrant/sources/hosts /etc/hosts
    sudo cp '/vagrant/sources/sources.list' '/etc/apt/'

    sudo apt update -y

    sudo apt-get install redis -y

    sudo cp /vagrant/conf/redis2.conf /etc/redis/redis.conf
    sudo cp /vagrant/conf/sentinel2.conf /etc/redis-sentinel.conf
    ```
    - `redis-3.sh`
    ```bash
    sudo cp /vagrant/sources/hosts /etc/hosts
    sudo cp '/vagrant/sources/sources.list' '/etc/apt/'

    sudo apt update -y

    sudo apt-get install redis -y

    sudo cp /vagrant/conf/redis3.conf /etc/redis/redis.conf
    sudo cp /vagrant/conf/sentinel3.conf /etc/redis-sentinel.conf
    ```
    - `wordpress.sh`
    ```bash
    sudo cp '/vagrant/sources/sources.list' '/etc/apt/'

    sudo apt update -y

    # Install Apache2
    sudo apt install apache2 -y
    sudo ufw allow in "Apache Full"

    # Install PHP
    sudo apt install php libapache2-mod-php php-mysql php-pear php-dev -y
    sudo a2enmod mpm_prefork && sudo a2enmod php7.0
    sudo pecl install redis
    sudo echo 'extension=redis.so' >> /etc/php/7.2/apache2/php.ini

    # Install MySQL
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'
    sudo apt install mysql-server -y
    sudo mysql_secure_installation -y
    sudo ufw allow 3306

    # Configure MySQL for Wordpress
    sudo mysql -u root -padmin < /vagrant/sql/wordpress.sql

    # Install Wordpress
    cd /tmp
    wget -c http://wordpress.org/latest.tar.gz
    tar -xzvf latest.tar.gz
    sudo mkdir -p /var/www/html
    sudo mv wordpress/* /var/www/html
    sudo cp /vagrant/wp-config.php /var/www/html/
    sudo chown -R www-data:www-data /var/www/html/
    sudo chmod -R 755 /var/www/html/
    sudo systemctl restart apache2
    ```
3. File Konfigurasi
    - `redis1.conf`
    ```bash
    bind 192.168.16.12
    port 6379

    dir "/etc/redis"
    ```
    - `redis2.conf`
    ```bash
    bind 192.168.16.13
    port 6379

    dir "/etc/redis"

    slaveof 192.168.16.12 6379
    ```
    - `redis3.conf`
    ```bash
    bind 192.168.16.14
    port 6379

    dir "/etc/redis"

    slaveof 192.168.16.12 6379
    ```
    - `sentinel1.conf`
    ```bash
    bind 192.168.16.12
    port 26379

    sentinel monitor redis-cluster 192.168.16.12 6379 2
    sentinel down-after-milliseconds redis-cluster 5000
    sentinel parallel-syncs redis-cluster 1
    sentinel failover-timeout redis-cluster 10000
    ```
    - `sentinel2.conf`
    ```bash
    bind 192.168.16.13
    port 26379

    sentinel monitor redis-cluster 192.168.16.12 6379 2
    sentinel down-after-milliseconds redis-cluster 5000
    sentinel parallel-syncs redis-cluster 1
    sentinel failover-timeout redis-cluster 10000
    ```
    - `sentinel3.conf`
    ```bash
    bind 192.168.16.14
    port 26379

    sentinel monitor redis-cluster 192.168.16.12 6379 2
    sentinel down-after-milliseconds redis-cluster 5000
    sentinel parallel-syncs redis-cluster 1
    sentinel failover-timeout redis-cluster 10000
    ```
4. File Tambahan
    - sources
        - hosts
        ```bash
        192.168.16.12 redis-master
        192.168.16.13 redis-slave
        192.168.16.14 redis-slave
        192.168.16.15 wordpress-redis
        192.168.16.16 wordpress-non
        ```
        - sources.list
        ```bash
        ## Note, this file is written by cloud-init on first boot of an instance
        ## modifications made here will not survive a re-bundle.
        ## if you wish to make changes you can:
        ## a.) add 'apt_preserve_sources_list: true' to /etc/cloud/cloud.cfg
        ##     or do the same in user-data
        ## b.) add sources in /etc/apt/sources.list.d
        ## c.) make changes to template file /etc/cloud/templates/sources.list.tmpl

        # See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
        # newer versions of the distribution.
        # deb http://archive.ubuntu.com/ubuntu bionic main restricted
        # deb-src http://archive.ubuntu.com/ubuntu bionic main restricted

        deb http://boyo.its.ac.id/ubuntu bionic main restricted

        ## Major bug fix updates produced after the final release of the
        ## distribution.
        # deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted
        # deb-src http://archive.ubuntu.com/ubuntu bionic-updates main restricted

        deb http://boyo.its.ac.id/ubuntu bionic-updates main restricted

        ## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
        ## team. Also, please note that software in universe WILL NOT receive any
        ## review or updates from the Ubuntu security team.
        # deb http://archive.ubuntu.com/ubuntu bionic universe
        # deb-src http://archive.ubuntu.com/ubuntu bionic universe
        # deb http://archive.ubuntu.com/ubuntu bionic-updates universe
        # deb-src http://archive.ubuntu.com/ubuntu bionic-updates universe

        deb http://boyo.its.ac.id/ubuntu bionic universe
        deb http://boyo.its.ac.id/ubuntu bionic-updates universe

        ## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
        ## team, and may not be under a free licence. Please satisfy yourself as to
        ## your rights to use the software. Also, please note that software in
        ## multiverse WILL NOT receive any review or updates from the Ubuntu
        ## security team.
        # deb http://archive.ubuntu.com/ubuntu bionic multiverse
        # deb-src http://archive.ubuntu.com/ubuntu bionic multiverse
        # deb http://archive.ubuntu.com/ubuntu bionic-updates multiverse
        # deb-src http://archive.ubuntu.com/ubuntu bionic-updates multiverse

        deb http://boyo.its.ac.id/ubuntu bionic multiverse
        deb http://boyo.its.ac.id/ubuntu bionic-updates multiverse

        ## N.B. software from this repository may not have been tested as
        ## extensively as that contained in the main release, although it includes
        ## newer versions of some applications which may provide useful features.
        ## Also, please note that software in backports WILL NOT receive any review
        ## or updates from the Ubuntu security team.
        # deb http://archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse
        # deb-src http://archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse

        deb http://boyo.its.ac.id/ubuntu bionic-backports main restricted universe multiverse

        ## Uncomment the following two lines to add software from Canonical's
        ## 'partner' repository.
        ## This software is not part of Ubuntu, but is offered by Canonical and the
        ## respective vendors as a service to Ubuntu users.
        # deb http://archive.canonical.com/ubuntu bionic partner
        # deb-src http://archive.canonical.com/ubuntu bionic partner

        # deb http://security.ubuntu.com/ubuntu bionic-security main restricted
        # deb-src http://security.ubuntu.com/ubuntu bionic-security main restricted
        # deb http://security.ubuntu.com/ubuntu bionic-security universe
        # deb-src http://security.ubuntu.com/ubuntu bionic-security universe
        # deb http://security.ubuntu.com/ubuntu bionic-security multiverse
        # deb-src http://security.ubuntu.com/ubuntu bionic-security multiverse

        deb http://boyo.its.ac.id/ubuntu bionic-security main restricted
        deb http://boyo.its.ac.id/ubuntu bionic-security universe
        deb http://boyo.its.ac.id/ubuntu bionic-security multiverse
        ```
    - sql
        - wordpress.sql
        ```bash
        CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

        CREATE USER 'user'@'%' IDENTIFIED BY 'password';
        GRANT ALL PRIVILEGES on wordpress.* to 'user'@'%';
        FLUSH PRIVILEGES;
        ```
## Konfigurasi Redis
`NOTE` ini semua dilakukan di terminal yang berbeda
- Masuk ke `redis1` dengan cara `sudo vagrant ssh redis1`
    - Ketikan
    ```bash
    sudo redis-server /etc/redis/redis.conf
    ```
    ![red1_server](https://user-images.githubusercontent.com/32433590/69501535-7bedf900-0f38-11ea-9654-226326cb5250.png)
    - Buka Terminal baru dan ketikan
    ```bash
    sudo redis-server /etc/redis-sentinel.conf --sentinel
    ```
    ![red1_sentinel](https://user-images.githubusercontent.com/32433590/69501534-7bedf900-0f38-11ea-9e82-3018ed26e442.png)
- Masuk ke `redis2` dengan cara `sudo vagrant ssh redis2`
    - Ketikan
    ```bash
    sudo redis-server /etc/redis/redis.conf
    ```
    ![red2_server](https://user-images.githubusercontent.com/32433590/69501537-7c868f80-0f38-11ea-9949-00fd85c2204a.png)
    - Buka Terminal baru dan ketikan
    ```bash
    sudo redis-server /etc/redis-sentinel.conf --sentinel
    ```
    ![red2_sentinel](https://user-images.githubusercontent.com/32433590/69501536-7c868f80-0f38-11ea-9917-caae925b95e0.png)
- Masuk ke `redis3` dengan cara `sudo vagrant ssh redis3`
    - Ketikan
    ```bash
    sudo redis-server /etc/redis/redis.conf
    ```
    ![red3_server](https://user-images.githubusercontent.com/32433590/69501539-7d1f2600-0f38-11ea-855b-b43927a15a78.png)
    - Buka Terminal baru dan ketikan
    ```bash
    sudo redis-server /etc/redis-sentinel.conf --sentinel
    ```
    ![red3_sentinel](https://user-images.githubusercontent.com/32433590/69501538-7c868f80-0f38-11ea-92ee-71a7e60c0111.png)
## Implementasi Replication
- Masuk ke `redis1` dengan cara `sudo vagrant ssh redis1`
    - Ketikkan
    ```bash
    redis-cli -h 192.168.16.12
    ```
    - Selanjutnya ketikan
    ```bash
    info replication
    ```
    ![repl_red1](https://user-images.githubusercontent.com/32433590/69501540-7db7bc80-0f38-11ea-9c5c-c2d9de45b4bc.png)

- Masuk ke `redis2` dengan cara `sudo vagrant ssh redis2`
    - Ketikkan
    ```bash
    redis-cli -h 192.168.16.13
    ```
    - Selanjutnya ketikan
    ```bash
    info replication
    ```
    ![repl_red2](https://user-images.githubusercontent.com/32433590/69501541-7db7bc80-0f38-11ea-8f7a-4cfae3bddaa5.png)
    
- Masuk ke `redis3` dengan cara `sudo vagrant ssh redis3`
    - Ketikkan
    ```bash
    redis-cli -h 192.168.16.14
    ```
    - Selanjutnya ketikan
    ```bash
    info replication
    ```
    ![repl_red3](https://user-images.githubusercontent.com/32433590/69501542-7e505300-0f38-11ea-9191-6adee0dc4b72.png)
    
## Install Wordpress pada server wordpress

## Fail Over Test
- Masuk ke `redis1` dengan cara `sudo vagrant ssh redis1` karena `redis1` ialah merupakan master
- Lalu ketikkan
```bash 
redis-cli -h 192.168.16.12 -p 6379 DEBUG sleep 60
```
![fail1](https://user-images.githubusercontent.com/32433590/69501590-e56e0780-0f38-11ea-9725-96f83e44d3ce.png)
- Lalu cek server `redis` yang lain disini ketika melakukan failover yang menjadi master selanjutnya ialah `redis3`. Maka lakukan `sudo vagrant ssh redis1`
- Lalu ketikkan
```bash
redis-cli -h 192.168.16.14
```
- Lalu cek info replikasi
```bash
info replication
```
![fail2](https://user-images.githubusercontent.com/32433590/69501591-e6069e00-0f38-11ea-9fad-140eac49007b.png)
## JMETER Test