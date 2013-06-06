#/bin/sh

mkdir awesomebox
cd awesomebox

curl -O http://nodejs.org/dist/v0.8.24/node-v0.8.24-darwin-x64.tar.gz
tar xzf node-v0.8.24-darwin-x64.tar.gz
rm node-v0.8.24-darwin-x64.tar.gz
mv node-v0.8.24-darwin-x64 node



# TENDERLOIN_TARGET="$HOME/tenderloin"
# 
# if [ -d "$TENDERLOIN_TARGET" ]; then
#   echo "Tenderloin is already installed in $TENDERLOIN_TARGET \n"
#   exit
# fi
# 
# git clone git://github.com/patrickod/tenderloin.git $TENDERLOIN_TARGET
# 
# cd $TENDERLOIN_TARGET
# 
# echo -n "Enter a heroku project name: "
# read HEROKU_TARGET
# 
# until heroku apps:create $HEROKU_TARGET
# do
#   echo -n "Enter a heroku project name: "
#   read HEROKU_TARGET
# done
# 
# DOMAIN_URL="http://$HEROKU_TARGET.herokuapp.com"
# 
# echo -n "Will you host this on a custom domain? [y/n] "
# read CUSTOM_DOMAIN
# 
# if [ "$CUSTOM_DOMAIN" == "y" ]; then
#   echo -n "Enter the domain you will use with Tenderloin: "
#   read DOMAIN_URL
#   heroku domains:add $DOMAIN_URL
#   heroku config:set DOMAIN_URL=$DOMAIN_URL
# fi
# 
# heroku addons:add redistogo:nano
# heroku addons:add mongohq:sandbox
# heroku config:set CABOOSE_ENV=production
# 
# git push heroku master
