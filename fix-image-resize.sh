#!/bin/bash

dir=$(dirname $(readlink -f $0))

cd $dir/magento

mkdir -p app/code/EcomDev/

cp -r $dir/improvement/EcomDev/ImageResizeFix app/code/EcomDev/

bin/magento setup:upgrade
rm -rf var/di var/generation
bin/magento setup:di:compile
bin/magento setup:static-content:deploy
composer dump-autoload
