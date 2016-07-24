#!/bin/bash

dir=$(dirname $(readlink -f $0))
path=$(basename $dir)
database=$1
domain=$2
version=$3

function usage()
{
    echo "Usage: ./setup.sh database-name domain-name [magento-version]";
    echo "  database-name       Name of the database which to use for installment";
    echo "  domain-name         Domain name of the test system";
    echo "  magento-version     Magento version to install, by default: latest";
    exit 1
}

if [[ $database == "" ]]
then
    echo "Please provide a database name as a first argument"
    usage
fi

if [[ $domain == "" ]]
then
    echo "Please provide a domain name as a second argument"
    usage
fi


if [[ $version == "" ]]
then
    version="latest"
fi

# Import database
mysql -e "drop database if exists $database; create database $database;"
MYSQLPASSWORD=$(awk -F "=" '/password/ {print $2}' ${HOME}/.my.cnf | sed -e 's/^[ \t]*//')
MYSQLUSER=$(awk -F "=" '/user/ {print $2}' ${HOME}/.my.cnf | sed -e 's/^[ \t]*//')
MYSQLHOST=$(awk -F "=" '/host/ {print $2}' ${HOME}/.my.cnf | sed -e 's/^[ \t]*//')

dbfile=$dir/db/data.sql.gz

if [ -f $dir/db/data-$version.sql.gz ]
then
    dbfile=$dir/db/data-$version.sql.gz
fi

gunzip < $dbfile | mysql $database

# Install magento configure it
mkdir $dir/magento
cd $dir/magento

wget -qO- https://magento.mirror.hypernode.com/releases/magento-$version.tar.gz | tar xfz -
chmod +x bin/magento

bin/magento setup:install --db-host="$MYSQLHOST" --db-name="$database" --db-user="$MYSQLUSER" \
    --db-password="$MYSQLPASSWORD" --admin-firstname=Admin --admin-lastname=User \
    --admin-user=admin --admin-password=Password123 --admin-email=test@example.com \
    --base-url="http://$domain/" --language=en_US --timezone=Europe/Amsterdam \
    --currency=USD --use-rewrites=1

n98-magerun2 config:set web/unsecure/base_url http://$domain/
n98-magerun2 config:set web/secure/base_url http://$domain/
n98-magerun2 config:set catalog/frontend/flat_catalog_category 1
n98-magerun2 config:set catalog/frontend/flat_catalog_product 1
n98-magerun2 config:set system/full_page_cache/caching_application 2
n98-magerun2 config:set system/full_page_cache/ttl 86400

composer config optimize-autoloader true
composer config classmap-authoritative true

bin/magento cache:flush
bin/magento indexer:reindex
bin/magento cache:enable
bin/magento deploy:mode:set production

cd $dir

[ ! -d ../public ] || rm ../public/*.txt
[ ! -d ../public ] || rmdir ../public

varnishadm vcl.load m2benchmark $dir/config/varnish.vcl
varnishadm vcl.use m2benchmark

bash $dir/config/media.sh $dir/magento/pub $dir/config/media.set $dir/config/media

ln -fsn $path/magento/pub ../public
