#!/bin/bash

dir=$(dirname $(readlink -f $0))

cd $dir/magento

# Category product relation indexer
bin/magento indexer:reindex catalog_category_product
bin/magento indexer:reindex catalog_product_category

# Stock inventory indexer
bin/magento indexer:reindex cataloginventory_stock 

# Price indexer
bin/magento indexer:reindex catalog_product_price

# Catalog product attribute indexer
bin/magento indexer:reindex catalog_product_attribute

# Catalog product flat indexer
bin/magento indexer:reindex catalog_product_flat

