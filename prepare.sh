#!/bin/bash

dir=$(dirname $(readlink -f $0))
path=$(basename $dir)
database=$1

if [[ $database == "" ]]
then
    echo "Please provide a database name as a first argument"
    exit 1
fi

cd $dir/magento

# Clean up existing orders, to not affect our load test
echo "
 SET foreign_key_checks=0;
 TRUNCATE downloadable_link_purchased;
 TRUNCATE paypal_billing_agreement_order;
 TRUNCATE sales_creditmemo;
 TRUNCATE sales_invoice;
 TRUNCATE sales_order_address;
 TRUNCATE sales_order_item;
 TRUNCATE sales_order_payment;
 TRUNCATE sales_order_status_history;
 TRUNCATE sales_payment_transaction;
 TRUNCATE sales_shipment;
 TRUNCATE sales_order;
 TRUNCATE quote_address;
 TRUNCATE quote_id_mask;
 TRUNCATE quote_item;
 TRUNCATE quote_payment;
 TRUNCATE quote;
" | mysql $database

# Clear caches for not affecting our load tests
n98-magerun2 cache:flush
varnishadm "ban req.url ~ /"
rm -rf pub/media/catalog/product/cache
