#!/bin/bash

set -e

echo -en "\n\nInitialize terraform modules....." && terraform init >/dev/null || exit 1  && echo "Success"

ATTEMPT=0

run_terraform () {
  echo -n "Generating random string......  " && terraform apply --target=random_string.random --auto-approve > /dev/null || exit 1 && echo $(terraform output|grep random_string|cut -d '"' -f2)
  if [ "$1" = "--silent" ]; then
    echo -n "Apply terraform......" && terraform apply --auto-approve >/dev/null || exit 1 && echo "Success"
  else
    echo -n "Apply terraform......\n\n" && terraform apply --auto-approve || exit 1 && echo -e "\n\n......Terraform applied successfully."
  fi
  echo -n "Delete Resource Group....." && $(terraform output|grep rg_delete_command|cut -d '"' -f2) >/dev/null || exit 1 && echo "Success"
  echo -n "Cleanup TFstate....." && rm -f terraform.tfstate* >/dev/null || exit 1 && echo "Success"
  echo -n "Sleeping 10 seconds to allow for Ctrl-C......." && sleep 10 && echo "Done"
}

while true; do
  let ATTEMPT+=1
  echo -e "\n\nAttempt # ${ATTEMPT}\n------------------------------------------------------"
  run_terraform $1 || echo -e "\n\n\nAttempt #${ATTEMPT} failed."
done
}
