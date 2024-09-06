APP_NAME=kube-scheduler
EXTENTION_DIR := $(shell pwd)/kube-scheduler-wasm-extension
BIN_DIR := $(shell pwd)/bin
CONFIG_DIR := $(shell pwd)/config
SCHEDULER = $(BIN_DIR)/$(APP_NAME)
GOOS := darwin

.PHONY build-kube-scheduler:
build-kube-scheduler:
	cd $(EXTENTION_DIR)/scheduler && GOOS=$(GOOS) go build -o $(BIN_DIR)/kube-scheduler ./cmd/scheduler

.PHONY start-kind:
start-kind:
	kind create cluster --config config/kind-config.yaml

.PHONY deploy-kube-scheduler:
deploy-kube-scheduler:
	docker cp $(BIN_DIR)/kube-scheduler kind-control-plane:/kube-scheduler
	docker cp $(CONFIG_DIR)/kube-scheduler.yaml kind-control-plane:/kube-scheduler.yaml
	docker cp kube-scheduler-wasm-extension/examples/nodenumber/main.wasm kind-control-plane:/main.wasm

.PHONY exec-control-plane:
exec-control-plane:
	docker exec -it kind-control-plane /bin/bash

.PHONY run-kube-scheduler:
run-kube-scheduler:
	docker exec -it kind-control-plane ./kube-scheduler --config=kube-scheduler.yaml --authentication-kubeconfig=/etc/kubernetes/scheduler.conf --authorization-kubeconfig=/etc/kubernetes/scheduler.conf --bind-address=127.0.0.1 --master=--authentication-kubeconfig=/etc/kubernetes/scheduler.conf--authorization-kubeconfig=/etc/kubernetes/scheduler.conf--bind-address=127.0.0.1--kubeconfig=/etc/kubernetes/scheduler.conf--leader-elect=true --secure-port=10200 --leader-elect=true --master=https://172.18.0.3:6443




.PHONY setup-simulator:
setup-simulator:
	mkdir -p download
	cd download && git clone git@github.com:kubernetes-sigs/kube-scheduler-simulator.git
	yq -i '.externalSchedulerEnabled |= true'  download/kube-scheduler-simulator/simulator/config.yaml
	sed -i '' 's/1212/1213/g'  download/kube-scheduler-simulator/simulator/config.yaml
	sed -i '' 's/1212/1213/g' download/kube-scheduler-simulator/docker-compose.yml


.PHONY run-simulator:
run-simulator: $(SCHEDULER)
	cd download/kube-scheduler-simulator && make docker_up

.PHONY build-wasm:
build-wasm:
	mkdir -p $(BIN_DIR)
	cd $(EXTENTION_DIR)/examples/nodenumber && tinygo build -o $(BIN_DIR)/main.wasm -scheduler=none --no-debug -target=wasi $(EXTENTION_DIR)/examples/nodenumber/main.go
