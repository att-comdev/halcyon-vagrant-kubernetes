#!/usr/bin/env bash

# Copyright 2016, AT&T, and it's Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
# Setting up kubectl creds
mkdir -p ${HOME}/.kube
if [ -f ${HOME}/.kube/config ]; then
    echo "Previous kube config found, backing it up"
    mv -v ${HOME}/.kube/config ${HOME}/.kube/config.$(date "+%F-%T")
fi
echo "Getting kubeconfig from kube1"
vagrant ssh kube1 -c "sudo cat /etc/kubernetes/admin.conf" > ${HOME}/.kube/config

# Setting up helm client if present
if which helm 2>/dev/null; then
  helm init --client-only
fi

echo "clients should now be ready to access the Kubernetes cluster"
