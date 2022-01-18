#!/bin/bash

containerOrganization="xldevdocker"
branchName="master"

if [[ $# -eq 0 ]] ; then
    printf "\e[31mProvide in a first parameter a version (SemVer compatible) to release !\e[m\n"
    echo "For example:"
    printf "\e[1;32m./build_operator.sh 22.0.0-114.1255 \e[0m"
    echo ""
    printf "\e[1;32m./build_operator.sh 22.0.0-114.1255 acierto\e[0m"
    echo ""
    printf "\e[1;32m./build_operator.sh 22.0.0-114.1255 acierto ENG-8769\e[0m"
    echo ""
    printf "Second example is about how to push the image to a non-default organization"
    echo ""
    printf "Third example shows how to push from the branch, even if you want to use the default organization, for a non-default branch you have to specify name for an organization."
    echo ""
    exit 1
fi

if [[ $# > 1 ]] ; then
  containerOrganization=$2
fi

if [[ $# > 2 ]] ; then
  branchName=$3
fi

mkdir xlr
cd xlr
git clone git@github.com:xebialabs/xl-release-kubernetes-helm-chart.git -b $branchName
cd xl-release-kubernetes-helm-chart
rm -f values-haproxy.yaml
mv values-nginx.yaml values.yaml
helm dependency update .
rm -f Chart.lock
cd ..
helm package xl-release-kubernetes-helm-chart
rm -rf xl-release-kubernetes-helm-chart
mv digitalai-release-*.tgz xlr.tgz
operator-sdk init --domain digital.ai --plugins=helm
operator-sdk create api --group=xlr --version=v1alpha1 --helm-chart=xlr.tgz
export OPERATOR_IMG="docker.io/$containerOrganization/release-operator:$1"
make docker-build docker-push IMG=$OPERATOR_IMG
cd ..
rm -rf xlr
