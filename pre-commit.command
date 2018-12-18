# Change to script directory
cd $(dirname "$0")

# Change Server build number
cat Server/BaaS-Server.php | sed -e 's/\$build = ".*"/$build = "'$(date "+%Y%m%d")'"/g' > Server/BaaS-Server.php

# Change Swift build number
cat Framework/BaaS/BaaS/BaaS.swift | sed -e 's/build = ".*"/build = "'$(date "+%Y%m%d")'"/g' > Framework/BaaS/BaaS/BaaS.swift

# Seep.
sleep 10