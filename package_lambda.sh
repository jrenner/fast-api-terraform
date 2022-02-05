#!/bin/bash

#zip -rqy baker-enc.zip . -x=*terraform* -x=*.git/* -x=./boto* -x=./botocore* -x=./moto* -x=./requests-mock* -x=./cfnlint* -x "tests/**" -x "experiments/**"
rm lambda-package.zip
zip -ry lambda-package.zip . -x=./*api* -x=*terraform* -x=*.git/* -x=./boto* -x=./botocore* -x=./moto* -x=./requests-mock* -x=./cfnlint* -x "tests/**" -x "experiments/**"
