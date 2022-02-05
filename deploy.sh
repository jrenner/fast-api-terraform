#!/bin/bash

# create lambda zip
./package_lambda.sh &&
# run terraform apply in the terraform dir, with auto approve on
terraform -chdir=terraform apply -auto-approve
echo "terraform deploy DONE"
