#!/bin/bash

# prepare all the required python + other files needed for the zipped lambda to be
# uploaded to aws. contain it in its own directory away from the base code, so it's disposable

#zip -rqy baker-enc.zip . -x=*terraform* -x=*.git/* -x=./boto* -x=./botocore* -x=./moto* -x=./requests-mock* -x=./cfnlint* -x "tests/**" -x "experiments/**"
#zip -ry lambda-package.zip . -x=./api/* \
#    -x=./*venv* \
#    -x=*terraform* \
#     -x=*.git/* -x=./boto* -x=./botocore* -x=./moto* -x=./requests-mock* -x=./cfnlint* -x "tests/**" -x "experiments/**"
BASE_DIR=$PWD
# all python lambda code is in this directory
cd test_lambda
mkdir -p deploy
# copy over all files from parent directory except this deploy dir
rsync -aP --exclude=deploy * deploy
# install requirments into deploy directory as directories to be packaged in the zip at base level
pip install -r requirements.txt -t deploy
cd deploy
# remove any previous packaged lambda
rm lambda-package.zip
# recursively zip, with exclusions as necessary, delete files after zipping
zip -rmy lambda-package.zip . -x="tests/**" -x=*.git/*
cd "$BASE_DIR"