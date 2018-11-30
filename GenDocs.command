# Get the base directory
BASEDIR=$(dirname $0)

# Move to the base directory
cd $BASEDIR

# Move to "Framework"
cd Framework

# Execute "Jazzy"
jazzy

# Move to the base directory
cd $BASEDIR

# Move to "Server"
cd Server

# Execute "phpDocumentor"
phpDocumentor

# Remove build files
rm -rf build

# Move to the base directory
cd $BASEDIR

# Remove build files
rm -rf build

# Bye!
exit &>/dev/null