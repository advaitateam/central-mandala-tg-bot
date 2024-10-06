#!/bin/sh
set -e

SERVICE_NAME=tg-bot
COMPANY_NAME=central-mandala
CMD=$1

case ${CMD} in
install)
  echo "Creating virtual envoiroment into venv folder"
  virtualenv --python=python3 venv
  source venv/bin/activate
  echo "Installing requirements"
  pip install -r requirements.txt
  echo "Copy pre commit hook"
  echo './make.sh lint' >> .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  ;;

lint)
  pylint ./
  ;;

bandit)
  bandit --exclude ./venv -ll -r ./
  if [ $? -ne 0 ]; then
    exit 1
  fi
  ;;

container-scan)
  snyk container test cr.advayta.org/$COMPANY_NAME/$SERVICE_NAME:latest
  ;;

deploy-dev)
  BRANCH_NAME=`git rev-parse --abbrev-ref HEAD`
  SHORT_SHA=`git rev-parse --short HEAD`
  echo $BRANCH_NAME, $SHORT_SHA
  docker build -t cr.advayta.org/$COMPANY_NAME/$SERVICE_NAME:$SHORT_SHA -t cr.advayta.org/$COMPANY_NAME/$SERVICE_NAME:latest --platform=linux/amd64 .
  # snyk container test cr.webdevelop.us/$COMPANY_NAME/$SERVICE_NAME:$SHORT_SHA
  if [ $? -ne 0 ]; then
    echo "===================="
    echo "snyk has found a vulnerabilities, please consider choosing alternative image from snyk"
    echo "===================="
  fi
  docker push cr.advayta.org/$COMPANY_NAME/$SERVICE_NAME:$SHORT_SHA
  docker push cr.advayta.org/$COMPANY_NAME/$SERVICE_NAME:latest
  ;;

help)
  @echo "Run cloud-config | install | lint | help"
  ;;

run-dev)
  python bot.py
  ;;

run)
  python bot.py
  ;;
esac
