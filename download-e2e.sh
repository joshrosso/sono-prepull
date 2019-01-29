#!/bin/bash

# Usage: ./download-e2e.sh $K8S_VERSION
# This creates a tarball of images for Kubernetes E2E tests that can be loaded on hosts to run
# E2E tests. This is accomplished by:
# 
# 1. Cloning github.com/kubernetes/kubernetes
# 2. Parsing kubernetes/test/utils/image/manifest.go
# 3. Downloading images locally using docker pull
# 4. Creating a tar of all images using docker save

function log {
  echo
  echo "$(tput setaf 3)===> $1$(tput sgr0)"
  echo
}

log "started download-e2e.sh"

if [ "${1}" = "1.13.2" ]
then
  SONOTAG="v0.11.5"
  CON_VER="v1.13"
elif [ "${1}" = "1.12.2" ] 
then
  SONOTAG="v0.12.2"
  CON_VER="v1.12"
elif [ "${1}" = "1.11.5" ] 
then
  SONOTAG="v0.11.5"
  CON_VER="v1.11"
else
  echo "ERROR: Must specify k8s version (e.g. 1.11.5). Or k8s version not known."
  exit
fi


# Download Kubernetes source for specified tag
K8S_SOURCE_DIR=$(mktemp -d)
log "$K8S_SOURCE_DIR created for temp storage of kuberenetes source"
log "cloning kubernetes to ${K8S_SOURCE_DIR}/kubernetes"
cd $K8S_SOURCE_DIR
git clone -b v${1} --single-branch --depth 1 https://github.com/kubernetes/kubernetes


# Parse source and compile list of images
cat kubernetes/test/utils/image/manifest.go | grep " = " | grep -o {.* |\
  sed '
    s/e2eRegistry/gcr.io\/kubernetes-e2e-test-images\//g
    s/gcRegistry/k8s.gcr.io\//g
    s/sampleRegistry/gcr.io\/google-samples\//g
    s/dockerLibraryRegistry/docker.io\/library\//g
    s/true/-amd64/g
    s/false\|{\|}\|"//g
    s/,//
    s/,/:/
    s/ \|,//g' >> images.txt
readarray imageList < images.txt


# For each image, format such that it's compatible with docker pull and save
for i in "${imageList[@]}"
do
  REPO=$(grep -o '.*:' <<< $i | sed s/://g)
  ARCH=$(grep -o '\-amd64' <<< $i )
  TAG=$(grep -o ':.*' <<< $i | sed s/-amd64//g)
  echo $TAG

  # skip write if cuda, only needed for GPU and image size is over 2GB
  if [[ $i =~ .*cuda.* ]]
  then
    echo "[OMITTED FROM IMAGE LIST] ${i}"
    continue
  fi

  # write list of images, formatted for docker commands
  echo ${REPO}${ARCH}${TAG}
  echo ${REPO}${ARCH}${TAG} >> imagesFormatted.txt
done
echo gcr.io/heptio-images/sonobuoy:${SONOTAG} >> imagesFormatted.txt
echo gcr.io/heptio-images/sonobuoy-plugin-systemd-logs:latest >> imagesFormatted.txt
echo gcr.io/heptio-images/kube-conformance:${CON_VER} >> imagesFormatted.txt


readarray formattedImageList < imagesFormatted.txt


# Create docker pull and docker save scripts
echo "#!/bin/bash" > pull_images.sh
echo "#!/bin/bash" > save_images.sh
echo -n "docker save -o e2e-${1}.tar " >> save_images.sh
for i in "${formattedImageList[@]}"
do
  # create an ngixn:latest tag, it's required by e2e test...which is crazy.
  if [[ $i =~ .*nginx.* ]]
  then
    RETAG="docker tag $(echo ${i} | sed -z 's/\n//g') nginx:latest"
  fi
  echo "docker pull ${i}" >> pull_images.sh
  echo -n "${i} " | sed -z 's/\n//g' >> save_images.sh
done
echo -e "\n\n" >> save_images.sh
echo "$RETAG" >> save_images.sh


# Run docker pull and docker save scripts
chmod +x pull_images.sh
log "pull_images.sh created ${K8S_SOURCE_DIR}/pull_images.sh"
chmod +x save_images.sh
log "save_images.sh created ${K8S_SOURCE_DIR}/save_images.sh"
log "pulling images locally"
. pull_images.sh
log "creating e2e-${1}.tar"
. save_images.sh
log "compressing and creating e2e-${1}.tar.gz"
tar -czvf e2e-${1}.tar.gz e2e-${1}.tar


# Finished
log "finished download-e2e.sh"
log "upload to server(s): ${K8S_SOURCE_DIR}/e2e-${1}.tar.gz.
     unpack with: tar zxvf e2e-${1}.tar.gz
     run docker load -i e2e-${1}.tar"
