# sono-prepull

This repository contains a workaround for https://github.com/heptio/sonobuoy/issues/160. It creates a `.tar.gz` of all required images. This package can be uploaded to hosts and after being unarchived, all images can be loaded locally with `docker load`. This works since `imagePullPolicy: ifNotPresent` is set.


Note, a preferrable workaround could be to write a MutatingWebhook controller, but this solution requires no additional running code.

## Usage

1. Clone the Repository

  ```
  git clone https://github.com/joshrosso/sono-prepull
  ```

1. Run `./download-e2e.sh $VERSION` ($VERSION is k8s version such 
as 1.13.2 & ensure user has docker access)

```
./download-e2e.sh 1.13.2

===> started download-e2e.sh


===> /tmp/tmp.0Hmj0M6ph2 created for temp storage of kuberenetes source


===> cloning kubernetes to /tmp/tmp.0Hmj0M6ph2/kubernetes

Cloning into 'kubernetes'...
load pubkey "/home/josh/.ssh/joshrosso.pem": invalid format
remote: Enumerating objects: 21089, done.
remote: Counting objects: 100% (21089/21089), done.
remote: Compressing objects: 100% (17413/17413), done.
remote: Total 21089 (delta 7063), reused 9473 (delta 3048), pack-reused 0
Receiving objects: 100% (21089/21089), 28.78 MiB | 7.35 MiB/s, done.
Resolving deltas: 100% (7063/7063), done.
Note: checking out 'cff46ab41ff0bb44d8584413b598ad8360ec1def'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

gcr.io/kubernetes-e2e-test-images/crd-conversion-webhook:1.13rev2
gcr.io/kubernetes-e2e-test-images/webhook:1.13v1
gcr.io/kubernetes-e2e-test-images/sample-apiserver:1.10
gcr.io/kubernetes-e2e-test-images/apparmor-loader:1.0
docker.io/library/busybox:1.29
gcr.io/kubernetes-e2e-test-images/metadata-concealment:1.1.1
gcr.io/kubernetes-e2e-test-images/cuda-vector-add:1.0
gcr.io/kubernetes-e2e-test-images/dnsutils:1.1
gcr.io/kubernetes-e2e-test-images/echoserver:2.2
gcr.io/kubernetes-e2e-test-images/entrypoint-tester:1.0
gcr.io/kubernetes-e2e-test-images/fakegitserver:1.0
gcr.io/google-samples/gb-frontend:v6
gcr.io/google-samples/gb-redisslave:v3
gcr.io/kubernetes-e2e-test-images/hostexec:1.1
gcr.io/kubernetes-e2e-test-images/ipc-utils:1.0
gcr.io/kubernetes-e2e-test-images/iperf:1.0
gcr.io/kubernetes-e2e-test-images/jessie-dnsutils:1.0
gcr.io/kubernetes-e2e-test-images/kitten:1.0
gcr.io/kubernetes-e2e-test-images/liveness:1.0
gcr.io/kubernetes-e2e-test-images/logs-generator:1.0
gcr.io/kubernetes-e2e-test-images/mounttest:1.0
gcr.io/kubernetes-e2e-test-images/mounttest-user:1.0
gcr.io/kubernetes-e2e-test-images/nautilus:1.0
gcr.io/kubernetes-e2e-test-images/net:1.0
gcr.io/kubernetes-e2e-test-images/netexec:1.1
gcr.io/kubernetes-e2e-test-images/nettest:1.0
docker.io/library/nginx:1.14
docker.io/library/nginx:1.15
gcr.io/kubernetes-e2e-test-images/nonewprivs:1.0
gcr.io/kubernetes-e2e-test-images/no-snat-test:1.0
gcr.io/kubernetes-e2e-test-images/no-snat-test-proxy:1.0
k8s.gcr.io/pause:3.1
gcr.io/kubernetes-e2e-test-images/porter:1.0
gcr.io/kubernetes-e2e-test-images/port-forward-tester:1.0
gcr.io/kubernetes-e2e-test-images/redis:1.0
gcr.io/kubernetes-e2e-test-images/resource-consumer:1.4
gcr.io/kubernetes-e2e-test-images/resource-consumer/controller:1.0
gcr.io/kubernetes-e2e-test-images/serve-hostname:1.1
gcr.io/kubernetes-e2e-test-images/test-webserver:1.0
gcr.io/kubernetes-e2e-test-images/volume/nfs:1.0
gcr.io/kubernetes-e2e-test-images/volume/iscsi:1.0
gcr.io/kubernetes-e2e-test-images/volume/gluster:1.0
gcr.io/kubernetes-e2e-test-images/volume/rbd:1.0.1

===> pull_images.sh created /tmp/tmp.0Hmj0M6ph2/pull_images.sh


===> save_images.sh created /tmp/tmp.0Hmj0M6ph2/save_images.sh


===> pulling images locally

1.13rev2: Pulling from kubernetes-e2e-test-images/crd-conversion-webhook
Digest: sha256:37f8c406ea2bfd468ac8e789f5fadd3775d9eb69db282b413fa672d05df5dc28
Status: Image is up to date for gcr.io/kubernetes-e2e-test-images/crd-conversion-webhook:1.13rev2
1.13v1: Pulling from kubernetes-e2e-test-images/webhook
Digest: sha256:72b7d368ad0a7c7db68687bbfb192c0f6a652c5f78db23ef791051eb702de132
Status: Image is up to date for gcr.io/kubernetes-e2e-test-images/webhook:1.13v1
1.10: Pulling from kubernetes-e2e-test-images/sample-apiserver
Digest: sha256:1bafcc6fb1aa990b487850adba9cadc020e42d7905aa8a30481182a477ba24b0
Status: Image is up to date for gcr.io/kubernetes-e2e-test-images/sample-apiserver:1.10
1.0: Pulling from kubernetes-e2e-test-images/apparmor-loader
Digest: sha256:1fdc224b826c4bc16b3cdf5c09d6e5b8c7aa77e2b2d81472a1316bd1606fa1bd
Status: Image is up to date for gcr.io/kubernetes-e2e-test-images/apparmor-loader:1.0

< REMOVED THE REST >

===> creating e2e-1.13.2.tar

write .docker_temp_750526932: no space left on device

===> compressing and creating e2e-1.13.2.tar.gz

===> finished download-e2e.sh

===> upload to server(s): /tmp/tmp.0Hmj0M6ph2/e2e-1.13.2.tar.gz.
     unpack with: tar zxvf e2e-1.13.2.tar.gz
     run docker load -i e2e-1.13.2.tar
```

1. Upload `e2e-$VERSION.tar.gz` to servers.

```
scp e2e-1.13.2.tar.gz ubuntu@$HOST
```

1. Unpack `e2e-$VERSION.tar.gz`.

```
tar zxvf e2e-1.13.2.tar.gz
```

1. Load images on every host.

```
docker load e2e-1.13.2.tar
```

