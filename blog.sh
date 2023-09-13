#!/bin/bash

k3d cluster delete -c k3d.yaml || true
k3d cluster create -c k3d.yaml

zarf init --confirm --components=git-server

zarf package deploy oci://ghcr.io/defenseunicorns/packages/metallb:0.0.1-amd64 --confirm --set=IP_ADDRESS_POOL=172.28.0.8/29
zarf package deploy oci://ghcr.io/defenseunicorns/packages/dubbd-k3d:0.8.0-amd64 --confirm --set=APPROVED_REGISTRIES="127.0.0.1* | ghcr.io/defenseunicorns/pepr* | ghcr.io/stefanprodan* | registry1.dso.mil"

# setup capability stuff
kubectl create namespace admin-ns-devs-do-not-access
kubectl create secret grafana-admin-api-key -n admin-ns-devs-do-not-access

cd pepr-grafana-capability && npx pepr build
zarf package create pepr-grafana-capability/dist --confirm --output .
zarf package deploy zarf-package-pepr-4a4d6cb5-d23b-5519-94be-315d013d9688-amd64-0.0.1.tar.zst --confirm