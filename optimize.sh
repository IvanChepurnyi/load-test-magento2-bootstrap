#!/bin/bash

dir=$(dirname $(readlink -f $0))
path=$(basename $dir)

cd $dir/magento/

rm -rf var/di var/generation var/cache
composer dump-autoload

# Disable modules that are config disabled by default in Magento 1.x, but enabled by default in 2.x
bin/magento module:disable Magento_Swatches

# Disable modules that we don't need for a load test scenario,
# in Magento 1.x it was not possible out of the box
bin/magento module:disable Magento_Ups
bin/magento module:disable Magento_Usps
bin/magento module:disable Magento_Dhl
bin/magento module:disable Magento_Braintree
bin/magento module:disable Magento_Paypal
bin/magento module:disable Magento_Authorizenet

bin/magento cache:flush
bin/magento setup:upgrade
bin/magento setup:di:compile
bin/magento setup:static-content:deploy

composer dump-autoload
