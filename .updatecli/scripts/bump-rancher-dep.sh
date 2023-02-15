#!/bin/sh
## This script updates the operator in go mod file and prints the resulting content in the stdout
## Please note that it will NEVER change the go.mod file (works in a temp directory)
##
## Expected arguments:
## - 1: the path to the go.mod file
## - 2: the new golang version in semver format (major.minor.patch)

set -eux

rancher_branch="${1}"
operator_version="${2}" 
go_mod_dir="${3}" 
file_to_print="${4}" ## go.mod or go.sum
tmp_dir="$(mktemp -d)"

## Clone rancher repo to a temp directory an start working from this temp. dir.
cd "${tmp_dir}" >&2
GOPATH="$(mktemp -d)"
export GOPATH
git clone https://github.com/alexander-demicev/rancher.git .
git checkout ${rancher_branch}

if [ "$go_mod_dir" = "pkg/apis" ]
then
  echo "Updating operator version in pkg/apis"
  cd pkg/apis >&2
fi

## Update go mod properly
go get "github.com/rancher/aks-operator@${operator_version}"
go mod tidy >&2
echo "" >> go.mod ## Add empty endline to be POSIX compliant
echo "" >> go.sum 

## Show new go.mod/go.sum content
cat ${file_to_print}
exit 0

