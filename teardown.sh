#!/bin/bash

if [ "$AWS_PROFILE" != "private" ]; then
    echo "AWS_PROFILE must be \"private\""
    exit 1
fi

terraform -chdir=terraform destroy -auto-approve
