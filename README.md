# kind-ignite-setup

[![CircleCI](https://circleci.com/gh/darkowlzz/kind-ignite-setup.svg?style=svg)](https://circleci.com/gh/darkowlzz/kind-ignite-setup)

Run kind k8s cluster backed by ignite VMs.
This is a proof of concept based on forked versions of
[kind](https://github.com/kubernetes-sigs/kind) and
[ignite](https://github.com/weaveworks/ignite) to make them work together. The
changes will be gradually implemented in the upstream kind and ignite repo for
official support.

## Building binaries

Use `make binaries` to build custom `kind` and `ignite` binaries on host. The
binaries will be copied to `bin/` dir. The build script clones the fork of kind
and ignite repo or if it finds existing kind and ignite repo, it adds the forks
as git remote and pulls the appropriate branch, and builds kind and ignite
binaries.

NOTE: At the moment, ignite uses a sandbox container image that's based on the
name of the branch it's built from. Due to this, the ignite binary may fail to
create VMs with error:
```
FATA[0007] failed to resolve reference "docker.io/weaveworks/ignite:ignite-kind-essentials": docker.io/weaveworks/ignite:ignite-kind-essentials: not found 
```
Until this becomes configurable, `weaveworks/ignite:v0.6.3` can be downloaded,
retagged to `weaveworks/ignite:ignite-kind-essentials`, saved as a tar file
and imported into the containerd runtime that ignite uses.

## Building images

To build a kind base and node images that are compatible with ignite VM, run:

```
$ make images
```

This uses a Dockerfile based on `weaveworks/ignite-ubuntu` and installs all the
necessary packages that kind base image includes. Once this image is built, it
is used to build kind node image. The build script will clone a version of
kubernetes repo and build kind node image against it. The k8s version can be set
using env var `K8S_REPO_VERSION`. Once the kind node image is ready, it can be
used by ignite to create k8s nodes. Build image script saves the images into tar
files in `bin/` directory. This is intended to be imported into ignite.

NOTE: At the moment, ignite doesn't support importing local container images.
The built kind node image must be uploaded to a container registry for ignite
to be able to import it. A workaround is to interact with docker or containerd
that ignite uses as runtime and import the image in them manually. The default
kind node image built above is `darkowlzz/node-ignite:test`. The saved tar file
for this image will be at `bin/node-ignite.tar`. Import it into containerd's
ignite namespace with `ctr -n firecracker images import node-ignite.tar`.
With this, ignite should be able to import the container image and build a VM
image to use. If using a container registry for the image, change the kind image
used in `scripts/setup.sh` to the appropriate image name.

## Create a kind cluster

Before using the above binaries and images to create a k8s cluster, run
`make deps` to install any dependencies that are needed to run ignite and this
kind-ignite setup. It'll install containerd, CNI binaries and kubectl.

Create a cluster:

```
$ make cluster
⚠️  Require root access to setup ignite VMs
bash scripts/setup.sh kind

Creating cluster "kind" ...
 ✓ Ensuring node image (darkowlzz/node-ignite:test) 🖼 
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Not sure what to do next? 😅 Check out https://kind.sigs.k8s.io/docs/user/quick-start/
node/kind-control-plane untainted

ℹ️  Run ". .env" to configure the current shell with the cluster.

Kubernetes cluster ready. Check the cluster nodes with:

  kubectl get nodes
```

By default, the name of the cluster is `kind`. The kubeconfig of this cluster will
be copied to the current directory as `kind-kubeconfig.yaml`. This can be used to
interact with the kind cluster.

Delete the cluster:

```
$ make clean
⚠️  Require root access to delete ignite VMs
bash scripts/destroy.sh kind

INFO[0000] Removing the container with ID "ignite-22c53f208ac516b9" from the "cni" network 
INFO[0020] Stopped VM with name "kind-worker" and ID "22c53f208ac516b9" 
INFO[0020] Removing the container with ID "ignite-75c38d73efc73ad9" from the "cni" network 
INFO[0041] Stopped VM with name "kind-control-plane" and ID "75c38d73efc73ad9" 
INFO[0041] Removing the container with ID "ignite-ab3c6df58ef5f6e8" from the "cni" network 
INFO[0062] Stopped VM with name "kind-worker2" and ID "ab3c6df58ef5f6e8" 
INFO[0000] Removed VM with name "kind-worker" and ID "22c53f208ac516b9" 
INFO[0000] Removed VM with name "kind-control-plane" and ID "75c38d73efc73ad9" 
INFO[0000] Removed VM with name "kind-worker2" and ID "ab3c6df58ef5f6e8" 

rm -f kind-kubeconfig.yaml
```

`kind-cluster.yaml` can be edited to change the kind cluster configuration.

Gist of an initial POC workflow
https://gist.github.com/darkowlzz/7a4a0a85723e0d542d0db46232cf75bf .


Prebuilt binaries can be downloaded for
[ignite](https://github.com/darkowlzz/ignite/releases/download/ignite-kind-essentials/ignite)
and
[kind](https://github.com/darkowlzz/kind/releases/download/ignite-support/kind-ignite-path).
They can be used with kind node image `darkowlzz/node-ignite:6`.

```
$ sudo ./bin/kind create cluster --image darkowlzz/node-ignite:6 --ignite=./bin/ignite --config=kind-cluster.yaml --name=kind
```
