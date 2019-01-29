#!/bin/bash

cyan="`tput setaf 3`"
norm="`tput sgr0`"
bold="`tput bold`"

function log {
  echo
  echo "${cyan}===> $1${norm}"
  echo
}

# get kubernetes source
log "started get images"

if [ -z "$1" ]
  then
    echo "ERROR: Must specify k8s version (e.g. 1.11.5)"
    exit
fi

K8S_SOURCE_DIR=$(mktemp -d)
log "$K8S_SOURCE_DIR created for temp storage of kuberenetes source"

log "cloning kubernetes to ${K8S_SOURCE_DIR}/kubernetes"
cd $K8S_SOURCE_DIR
git clone -b v${1} --single-branch --depth 1 https://github.com/kubernetes/kubernetes

# do scary things to determine images
cat kubernetes/test/utils/image/manifest.go | grep " = " | grep -o {.* |\
  sed '
    s/e2eRegistry/gcr.io\/kubernetes-e2e-test-images\//g
    s/gcRegistry/k8s.gcr.io\//g
    s/sampleRegistry/gcr.io\/google-samples\//g
    s/true/-amd64/g
    s/false\|{\|}\|"//g
    s/,//
    s/,/:/
    s/ \|,//g' > file.txt

readarray a < file.txt


for i in "${a[@]}"
do
  REPO=$(grep -o '.*:' <<< $i | sed s/://g)
  ARCH=$(grep -o '\-amd64' <<< $i )
  TAG=$(grep -o ':.*' <<< $i | sed s/-.*//g)
  echo ${REPO}${ARCH}${TAG}
  echo ${REPO}${ARCH}${TAG} >> places.txt
done

readarray b < places.txt
echo "#!/bin/bash" > pull_images.sh
echo "#!/bin/bash" > save_images.sh
echo -n "docker save -o e2e.tar.gz " >> save_images.sh


for i in "${b[@]}"
do
  echo "docker pull ${i}" >> pull_images.sh
  echo -n "${i} " | sed -z 's/\n//g' >> save_images.sh
done

chmod +x pull_images.sh
log "pull_images.sh created ${K8S_SOURCE_DIR}/pull_images.sh"
chmod +x save_images.sh
log "pull_images.sh created ${K8S_SOURCE_DIR}/save_images.sh"


log "pulling images locally"
. pull_images.sh

log "creating e2e.tar.gz"
. save_images.sh

log "completed. upload ${K8S_SOURCE_DIR}/save_images.sh to servers and run docker load"
