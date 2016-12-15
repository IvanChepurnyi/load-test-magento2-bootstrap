#!/bin/bash

dir=$(dirname $(readlink -f $0))

cd $dir/magento

mkdir -p app/code/EcomDev/

cp -r $dir/improvement/EcomDev/AjaxReviewFix app/code/EcomDev/
cp -r $dir/improvement/EcomDev/PageCacheFix app/code/EcomDev/

rm -rf var/di var/generation var/cache
composer dump-autoload

bin/magento setup:upgrade

bin/magento setup:di:compile
bin/magento setup:static-content:deploy

composer dump-autoload
