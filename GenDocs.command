BASEDIR=$(dirname "$0")

echo 'Change to script directory'
echo $BASEDIR

cd $BASEDIR

echo 'Change Server build number'
sed -i -e 's/build = ".*"/build = "'$(date "+%Y%m%d")'"/g' Server/BaaS-Server.php
rm Server/BaaS-Server.php-e

echo 'Change Swift build number'
sed -i -e 's/build = ".*"/build = "'$(date "+%Y%m%d")'"/g' Framework/BaaS/BaaS/BaaS-Main.swift
rm Framework/BaaS/BaaS/BaaS-Main.swift-e

# echo 'Sleeping.'
# sleep 1

echo 'Move to "Framework"'
cd Framework

echo 'Execute "Jazzy"'
jazzy

echo 'Move to the base directory'
cd $BASEDIR

echo 'Move to "Server"'
cd Server

echo 'Execute "phpDocumentor"'
phpDocumentor

echo 'Remove build files'
rm -rf build

echo 'Move to the base directory'
cd $BASEDIR

echo 'Remove build files'
rm -rf build

echo 'Bye!'

cd $BASEDIR

git add -A .
git commit -m 'Updated documentation'
git push

cd ..
cd BackendasaService.github.io
cd APIDocumentation
php _generate.php
cd ..

git add -A .
git commit -m 'Updated documentation'
git push

exit &>/dev/null