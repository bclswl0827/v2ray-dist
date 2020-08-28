#!/bin/sh

# This file is for the upgrading process of V2Ray on mipsle based router.
# Original source is located at github.com/bclswl0827/v2ray-dist/blob/master/upgrade.sh

# ENV
DIST_SRC='jsdelivr' # 'jsdelivr' or 'github'
TMP_FILE='/tmp/v2ray/v2ray-linux-mipsle.tar.gz'
RESTART_SSR='1' # Restart ShadowsocksR-Plus after upgrading.
CURRENT_VERSION=`/usr/bin/v2ray/v2ray -version | head -n 1 | cut -d " " -f2`
LATEST_VERSION=`curl --insecure -s --retry 10 --connect-timeout 10 https://api.github.com/repos/bclswl0827/v2ray-dist/releases/latest | grep "tag_name" | cut -d\" -f4 | sed "s/v//g"`

# Get download link
if [[ "${DIST_SRC}" == "jsdelivr" ]]; then
    DOWNLOAD_LINK="https://cdn.jsdelivr.net/gh/bclswl0827/v2ray-dist/dist/v${LATEST_VERSION}/v2ray-linux-mipsle.tar.gz"
else
    DOWNLOAD_LINK="https://raw.githubusercontent.com/bclswl0827/v2ray-dist/master/dist/v${LATEST_VERSION}/v2ray-linux-mipsle.tar.gz"
fi

# Upgrade V2Ray
if [ $(echo "${LATEST_VERSION}" | sed "s/\.//g") -gt $(echo "${CURRENT_VERSION}" | sed "s/\.//g") ] ; then
    echo -e "\033[44;37m Download new version of V2Ray v$LATEST_VERSION. \033[0m" 
    rm -rf $(echo ${TMP_FILE} | sed "s/v2ray-linux-mipsle.tar.gz//g")
    mkdir -p $(echo ${TMP_FILE} | sed "s/v2ray-linux-mipsle.tar.gz//g")
    echo -e "\033[44;37m Downloading V2Ray: ${DOWNLOAD_LINK} \033[0m"
    curl -L --retry 10 --connect-timeout 10 -H "Cache-Control: no-cache" -o ${TMP_FILE} ${DOWNLOAD_LINK}
else
    echo -e "\n\033[36m Latest version v${CURRENT_VERSION} of V2Ray is already installed, exiting. \036"
    exit 0
fi

# Install V2Ray and restart services
if [ $(curl --head -s ${DOWNLOAD_LINK} | grep "Content-Length" | sed "s/Content-Length: //g") -eq $(wc -c ${TMP_FILE} | sed "s/v2ray-linux-mipsle.tar.gz//g" | sed "s/v2ray//g" | sed "s/\///g" | tr -d " a-zA-z") ]; then
    tar -C /usr/bin/v2ray -xzf ${TMP_FILE}
	chmod 755 /usr/bin/v2ray/v2ray
    echo -e "\n\033[36m Successfully upgraded V2Ray to v${LATEST_VERSION}. \036"
    if [ "${RESTART_SSR}" -eq 1 ]; then
        rm -rf $(echo ${TMP_FILE} | sed "s/v2ray-linux-mipsle.tar.gz//g")
        echo -e "\033[33m Restart ShadowsocksR-Plus. \033[0m"
        /etc/init.d/shadowsocksr restart
    else
        rm -rf $(echo ${TMP_FILE} | sed "s/v2ray-linux-mipsle.tar.gz//g")
        echo -e "\033[33m V2Ray will be upgraded to v${LATEST_VERSION} on next boot. \036"
    fi
else
    echo -e "\n\033[31m Upgrading failed (Download failure)! \033[0m"
	rm -rf $(echo ${TMP_FILE} | sed "s/v2ray-linux-mipsle.tar.gz//g")
    exit 1
fi
