pushd /tmp
    git clone https://github.com/schnoddelbotz/amtc
popd

ls -lah /tmp/amtc/src/

# https://openwrt.org/docs/guide-developer/using_the_sdk

export DOCKER_IMAGE="openwrtorg/sdk:ar71xx-generic-19.07.4" # Alternatively rychly/openwrt-sdk:18.06.2-ar71xx

docker pull "${DOCKER_IMAGE}"

docker run --name openwrt-sdk -v ${PWD}:${PWD} -v /tmp/amtc:/tmp/amtc --workdir ${PWD} "${DOCKER_IMAGE}"

# Vim is needed for the xxd tool
apt update
apt install vim git

cd $SDK_HOME
./scripts/feeds update -a
./scripts/feeds install curl
cd -

cp ${PWD}/.config $SDK_HOME/.config
cd -
## This config is normally created by the menuconfig
##echo 'CONFIG_PACKAGE_libcurl=m' >> .config
#echo 'CONFIG_LIBCURL_GNUTLS=y' >> .config
#echo 'CONFIG_LIBCURL_CRYPTO_AUTH=y' >> .config


make V=99 package/curl/compile


cp feeds.conf.default feeds.conf
cd -
echo "src-link mypackages ${PWD}/mypackages" >> $SDK_HOME/feeds.conf
cd $SDK_HOME
./scripts/feeds update mypackages
./scripts/feeds install amtc

# Normally you would have to do menuconfig here as well
# echo 'CONFIG_PACKAGE_amtc=m' >> .config

make V=99 package/amtc/compile


ls -lah ./staging_dir/target-mips_24kc_musl/root-ar71xx/usr/bin/amtc
