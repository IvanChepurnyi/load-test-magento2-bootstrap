#!/bin/bash

dir=$(dirname $(readlink -f $0))

cd $dir/magento

read -d '' script << PHP
<?php
\$composer = json_decode(file_get_contents('composer.json'), true);
if (!is_array(\$composer['autoload']['psr-0'][''])) {
    \$composer['autoload']['psr-0'][''] = [\$composer['autoload']['psr-0'][''], 'var/generation'];
}
if (!isset(\$composer['autoload']['exclude-from-classmap'])) {
    \$composer['autoload']['exclude-from-classmap'] = ['**/dev/**', '**/update/**', '**/Test/**'];
}

file_put_contents('composer.json', json_encode(\$composer, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES));

PHP

phpscript=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo $script > /tmp/$phpscript

php -f /tmp/$phpscript
rm /tmp/$phpscript

composer config optimize-autoloader true
composer dump-autoload
