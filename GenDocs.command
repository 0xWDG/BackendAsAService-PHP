echo 'Change to script directory'
echo $(dirname "$0")

cd $(dirname "$0")

echo 'Change Server build number'
sed -i -e 's/build = ".*"/build = "'$(date "+%Y%m%d")'"/g' Server/BaaS-Server.php
rm Server/BaaS-Server.php-e

echo 'Change Swift build number'
sed -i -e 's/build = ".*"/build = "'$(date "+%Y%m%d")'"/g' Framework/BaaS/BaaS/BaaS.swift
rm Framework/BaaS/BaaS/BaaS.swift-e

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

git add -A .
git commit -m 'Updated documentation'
git push

cd ../BackendasaService.github.io
git add -A .
git commit -m 'Updated documentation'
git push

exit &>/dev/null