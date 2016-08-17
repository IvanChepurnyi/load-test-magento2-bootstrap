#!/bin/bash

dir=$(dirname $(readlink -f $0))
path=$(basename $dir)

cd $dir/magento

# Clear caches for not affecting our load tests
mysql -e 'RESET QUERY CACHE;'
n98-magerun2 cache:flush
varnishadm "ban req.url ~ /"
