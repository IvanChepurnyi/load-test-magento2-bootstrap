#!/bin/bash

dir=$(dirname $(readlink -f $0))
path=$(basename $dir)
database=$1
domain=$2
version=$3
databaseVersion=$4

function usage()
{
    echo "Usage: ./setup.sh database-name domain-name [magento-version] [database-variation]";
    echo "  database-name       Name of the database which to use for installment";
    echo "  domain-name         Domain name of the test system";
    echo "  magento-version     Magento version to install, by default: latest";
    echo "  database-variation  Special variation of database to install: original, large";
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

if [[ $databaseVersion == "" ]]
then
    databaseVersion=""
fi


# Import database
mysql -e "drop database if exists $database; create database $database;"
MYSQLPASSWORD=$(awk -F "=" '/password/ {print $2}' ${HOME}/.my.cnf | sed -e 's/^[ \t]*//')
MYSQLUSER=$(awk -F "=" '/user/ {print $2}' ${HOME}/.my.cnf | sed -e 's/^[ \t]*//')
MYSQLHOST=$(awk -F "=" '/host/ {print $2}' ${HOME}/.my.cnf | sed -e 's/^[ \t]*//')

dbfile=$dir/db/data.sql.gz

if [ -f $dir/db/data-$databaseVersion-$version.sql.gz ]
then
   dbfile=$dir/db/data-$databaseVersion-$version.sql.gz
elif [ -f $dir/db/data-$version.sql.gz ]
then
   dbfile=$dir/db/data-$version.sql.gz
elif [ -f $dir/db/data-$databaseVersion.sql.gz ]
then
   dbfile=$dir/db/data-$databaseVersion.sql.gz
fi

echo "Importing $dbfile"

gunzip < $dbfile | mysql $database

fixFile=$dir/db/data-fix-$version.sql

if [ -f $fixFile ]
then
   echo "Fixing setup_module table for $version, as structure didn't change but module setup version did"
   mysql $database < $fixFile
fi

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

# Enable redis cache in Magento 2
LOCAL_XML=$dir/magento/app/etc/env.php php $dir/config/configure-redis.php

n98-magerun2 config:set web/unsecure/base_url http://$domain/
n98-magerun2 config:set web/secure/base_url http://$domain/
n98-magerun2 config:set catalog/frontend/flat_catalog_category 1
n98-magerun2 config:set catalog/frontend/flat_catalog_product 1
# Make same category product per page positions as in Magento 1.0
n98-magerun2 config:set catalog/frontend/grid_per_page_values "12,24,36"
n98-magerun2 config:set catalog/frontend/grid_per_page "12"
n98-magerun2 config:set system/full_page_cache/caching_application 2
n98-magerun2 config:set system/full_page_cache/ttl 86400
n98-magerun2 config:set dev/grid/async_indexing 1
n98-magerun2 config:set sales_email/general/async_sending 1

bin/magento cache:flush
bin/magento indexer:reindex cataloginventory_stock
bin/magento indexer:reindex
bin/magento cache:enable
bin/magento deploy:mode:set production

composer config optimize-autoloader true
composer dump-autoload

cd $dir

[ ! -d ../public ] || rm ../public/*.txt
[ ! -d ../public ] || rmdir ../public

varnishadm vcl.load m2benchmark $dir/config/varnish.vcl
varnishadm vcl.use m2benchmark

bash $dir/config/media.sh $dir/magento/pub $dir/config/media.set $dir/config/media

ln -fsn $path/magento/pub ../public
