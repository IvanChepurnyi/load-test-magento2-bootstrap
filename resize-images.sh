#!/bin/bash

dir=$(dirname $(readlink -f $0))

bash $dir/fix-image-resize.sh

cd $dir/magento

bin/magento catalog:images:resize
