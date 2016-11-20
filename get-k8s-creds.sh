#/bin/sh
# Setting up kubectl creds
mkdir -p ${HOME}/.kube
if [ -f ${HOME}/.kube/config ]; then
    echo "Previous kube config found, backing it up"
    mv -v ${HOME}/.kube/config ${HOME}/.kube/config.$(date "+%F-%T")
fi
vagrant ssh kube1 -c "sudo cat /etc/kubernetes/admin.conf" > ${HOME}/.kube/config
