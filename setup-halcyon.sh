#/bin/bash
set -e
# This script simply sets up the basic defaults for a number of development
# senarios, it is written not to be elegant, but to be portable across a wide
# number of platforms with no addtional requirements other than bash.

: ${HALCYON_GROUP_VARS:="./halcyon-kubernetes/kube-deploy/group_vars/all.yml"}
: ${VAGRANT_VARS:="./config.rb"}
: ${BOOTSTRAP_OS:="ubuntu"}
: ${KUBERNETES_CONFIG:="default"}
: ${KUBERNETES_VERSION:="v1.5.1"}

usage(){
cat <<'EOT'
Call this script with...
--k8s-config (-c) [default|kolla]
--guest-os (-g) [ubuntu|centos]
--k8s-version (-v) [kubernetes version]
EOT
exit 0;
}

# exit if there are no arguments
[ $# -eq 0 ] && usage

set -- `getopt -n$0 -u -a --longoptions "help guest-os: k8s-config: k8s-version:" "hg:c:v:" "$@"`

# $# is the number of arguments
while [ $# -gt 0 ]
do
case "$1" in
-g|--guest-os) BOOTSTRAP_OS="$2"; shift;;
-c|--k8s-config) KUBERNETES_CONFIG="$2"; shift;;
-v|--k8s-version) KUBERNETES_VERSION="$2"; shift;;
-h| --help) usage;;
--) shift;break;;
*) break;;
esac
shift
done

cleanup_before_exit () {
echo -e "Running cleanup code and exiting"
}
trap cleanup_before_exit EXIT


set_yml_value () {
  VARIABLE=$1
  VALUE=$2
  FILE=$3
  sed -i "/^${VARIABLE}/c\\${VARIABLE}: ${VALUE}" ${FILE}
}

set_rb_value () {
  VARIABLE=$1
  VALUE=$2
  FILE=$3
  sed -i "/^\$${VARIABLE}/c\\\$${VARIABLE} = ${VALUE}" ${FILE}
}

set_kolla_options () {
  BOOL_VALUE=$1
  for VARIABLE in docker_shared_mounts setup_host_kube_dns setup_host_ceph patch_kube_ceph
  do
    set_yml_value ${VARIABLE} ${BOOL_VALUE} ${HALCYON_GROUP_VARS}
  done
}

echo "Setting up halcyon for: ${BOOTSTRAP_OS} with kubernetes ${KUBERNETES_VERSION} ($KUBERNETES_CONFIG)"

if [[ "$BOOTSTRAP_OS" = "centos" ]]; then
  set_rb_value kube_version \"centos/7\" ${VAGRANT_VARS}
  set_yml_value bootstrap_os centos ${HALCYON_GROUP_VARS}

  set_rb_value public_iface \"eth1\" ${VAGRANT_VARS}
  set_yml_value public_iface eth0 ${HALCYON_GROUP_VARS}
  set_yml_value nat_iface eth0 ${HALCYON_GROUP_VARS}

  set_rb_value ssh_user \"centos\" ${VAGRANT_VARS}

  set_rb_value os_image \"centos-7.2\" ${VAGRANT_VARS}

elif [[ "$BOOTSTRAP_OS" = "ubuntu" ]]; then
  set_rb_value kube_version \"ubuntu/xenial64\" ${VAGRANT_VARS}
  set_yml_value bootstrap_os ubuntu ${HALCYON_GROUP_VARS}

  set_rb_value public_iface \"enp0s8\" ${VAGRANT_VARS}
  set_yml_value public_iface enp0s3 ${HALCYON_GROUP_VARS}
  set_yml_value nat_iface enp0s3 ${HALCYON_GROUP_VARS}

  set_rb_value ssh_user \"ubuntu\" ${VAGRANT_VARS}

  set_rb_value os_image \"ubuntu-trusty-16.04\" ${VAGRANT_VARS}

fi


if [[ "$KUBERNETES_CONFIG" = "default" ]]; then
  set_kolla_options "false"

  set_rb_value kube_memory 1024 ${VAGRANT_VARS}
  set_rb_value kube_vcpus 1 ${VAGRANT_VARS}

  set_rb_value kube_count 3 ${VAGRANT_VARS}
  set_rb_value kube_workers \"kube[2:3]\" ${VAGRANT_VARS}

elif [[ "$KUBERNETES_CONFIG" = "kolla" ]]; then
  set_kolla_options "true"

  set_rb_value kube_memory 2048 ${VAGRANT_VARS}
  set_rb_value kube_vcpus 2 ${VAGRANT_VARS}

  set_rb_value kube_count 4 ${VAGRANT_VARS}
  set_rb_value kube_workers \"kube[2:4]\" ${VAGRANT_VARS}

fi

set_yml_value kube_version ${KUBERNETES_VERSION} ${HALCYON_GROUP_VARS}
