# Desciption

This is a collection of scripts and tools that can be used to run kube-scheduler-wasm-extension easily.

# Setup

## install tinygo

https://tinygo.org/getting-started/install/

## Setup repository

```console
git submodule update --init --recursive
```

## Build kube-scheduler

```console
make build-kube-scheduler
```

## Build wasm binary

```console
make build-wasm
```

## install kube-scheduler-simulator

```console
make setup-simulator
```

# Run

```console
make run-simulator
./bin/kube-scheduler --config=simulator-config/config.yaml
```
