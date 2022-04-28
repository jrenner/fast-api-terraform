#!/bin/bash

if [ "$AWS_PROFILE" != "private" ]; then
    echo "AWS_PROFILE must be \"private\""
    exit 1
fi

# create lambda zip
black test_lambda
./package_lambda.sh &&
# run terraform apply in the terraform dir, with auto approve on
terraform -chdir=terraform apply -auto-approve
echo "terraform deploy DONE"
