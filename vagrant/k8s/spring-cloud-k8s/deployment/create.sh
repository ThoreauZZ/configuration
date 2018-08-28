#!/bin/bash

project=$1

cp cloud-server-config.yaml ${project}.yaml
sed -i s#cloud-server-config#"${project}"#g ${project}.yaml
