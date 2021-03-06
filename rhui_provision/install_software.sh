#!/bin/sh
source ./vars

if [ ! -f ${ANSIBLE_INVENTORY} ]; then
  echo "Unable to find ansible hosts file: ${ANSIBLE_INVENTORY}"
  exit
fi

if [ ! -d ${LOG_DIR} ]; then
  mkdir ${LOG_DIR}
fi

usage() {
echo "Options"
echo " -p      Optional packages to install on RHUA/CDS (default: $PACKAGES)"
echo " -i      Install RHUA/CDS software from ISO (default: $ISO_PATH)"
echo " -m      Install Monitor software from RPM (default: $MON_RPM_PATH)"
echo " -r      Install RHUA Monitor software from RPM default: $RHUA_MON_RPM_PATH"
echo " -h      Help"
exit 2
}

while getopts ":p:,:i:,:h:,:m:" opt; do
    case $opt in
        h)     usage;;
        p)     PACKAGES=$OPTARG;;
        i)     ISO_PATH=$OPTARG;;
        m)     MON_RPM_PATH=$OPTARG;;
        \?)    break;; # end of options
    esac
done

if [ ! -z "$ISO_PATH" ]; then
  ISO_PATH=`readlink -f $ISO_PATH`
  ISO_FILENAME=`echo $ISO_PATH | rev | cut -f1 -d'/' | rev`
fi

ansible-playbook install_v2_software.yml -i ${ANSIBLE_INVENTORY} -vv --private-key=${EC2_SSH_PRIV_KEY} --extra-vars "iso_path=$ISO_PATH rhui_iso_filename=$ISO_FILENAME region=$REGION monitor_service_rpm_path=$MON_RPM_PATH rhua_monitor_service_rpm_path=$RHUA_MON_RPM_PATH" | tee ${LOG_DIR}/install_software.log

if [ "$?" -ne "0" ]; then
	echo "ansible-playbook failed with non-zero return."
	exit 1
fi

if [ ! -z "$PACKAGES" ]; then
    IFS=',' read -a array <<< "$PACKAGES"
    for element in "${array[@]}"
    do
        PKG=`readlink -f $element`
        PKG_NAME=`echo $PKG | rev | cut -f1 -d'/' | rev`
        ansible-playbook install_optional_pkg.yml -i ${ANSIBLE_INVENTORY} -vv --private-key=${EC2_SSH_PRIV_KEY} --extra-vars "pkg=$PKG pkg_name=$PKG_NAME" | tee ${LOG_DIR}/install_optional_pkg.log
    done
fi
