echo 'Change to script directory'
cd $(dirname "$0")

echo 'Change Server build number'
sed -i -e 's/build = ".*"/build = "'$(date "+%Y%m%d")'"/g' Server/BaaS-Server.php

echo 'Change Swift build number'
sed -i -e 's/build = ".*"/build = "'$(date "+%Y%m%d")'"/g' Framework/BaaS/BaaS/BaaS.swift

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
exit &>/dev/null