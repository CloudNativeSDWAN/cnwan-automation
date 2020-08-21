# Cloud Native SD-WAN Automation

This a collection of automation code for deploying cloud native SD-WAN setups.

CNWAN Automation is part of the Cloud Native SD-WAN (CNWAN) project. Please
check the [CNWAN documentation](https://github.com/CloudNativeSDWAN/cnwan-docs)
for the general project overview and architecture. You can contact the CNWAN
team at [cnwan@cisco.com](mailto:cnwan@cisco.com).

## Overview

This repo is intended as a place to collect tools for automating the
deployment of CNWAN setups in different environments. We plan to organize it
by the type of automation used.

A [Fish scripting library](./fish-scripting) is available currently, which is
a collection of imperative automation scripts written in the Fish shell in
order to create a CNWAN deployment on GCP. Please check its
[README](./fish-scripting/README.md) for details on how to use it.
