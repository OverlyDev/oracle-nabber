#!/bin/bash

set -e
if [ -f ".env" ]; then
    set -a; source ".env"; set +a
fi

# Check for required settings in .env
errors=0
declare -a required
required+=("USER_OCID" "FINGERPRINT" "PRIVATE_KEY_FILE" "TENANCY_OCID" "REGION_NAME")

for i in "${required[@]}"; do
    if [ -z "${!i}" ]; then
        errors+=1
        printf "Missing %s in .env\n" "$i"
    fi
done

# Bail if required settings are missing
if [ "$errors" -gt 0 ]; then
    echo "Ensure required .env settings are filled"
    exit 1
fi

echo "Generating config file"
cat > config <<EOL
[DEFAULT]
user=${USER_OCID}
fingerprint=${FINGERPRINT}
key_file=$(pwd)/${PRIVATE_KEY_FILE}
tenancy=${TENANCY_OCID}
region=${REGION_NAME}
EOL

echo "Fixing private key and config permissions"
oci setup repair-file-permissions --file "${PRIVATE_KEY_FILE}"
oci setup repair-file-permissions --file ./config

# Get availability domains
printf "\nAVAILABILITY DOMAINS\n"
data=$(oci --config-file ./config iam availability-domain list --all --compartment-id="${TENANCY_OCID}")
echo "${data}" | sed -n '/name\|"id"/Ip'

# Get shapes
printf "\nSHAPES\n"
printf "Feel free to choose one of the shapes below, but for the free tier your options are:\n"
printf "\t ARM: VM.Standard.A1.Flex\n"
printf "\t x86: VM.Standard.E2.1.Micro\n\n"
data=$(oci --config-file ./config compute shape list --compartment-id="${TENANCY_OCID}")
echo "${data}" | sed -n '/processor-description\|"shape"/Ip'

# Get network
printf "\nNETWORKS\n"
printf "If you don't have any networks listed, spin up a VM via the website to auto-create one\n\n"
data=$(oci --config-file ./config network subnet list --compartment-id="${TENANCY_OCID}")
echo "${data}" | sed -n '/display-name\|"id"/Ip'

# Get images
printf "\nIMAGES\n"
if [ -z "${SHAPE}" ]; then
    printf "Ensure you have a shape configured in the env in order to fetch compatible images\n"
else
    data=$(oci --config-file ./config compute image list --compartment-id="${TENANCY_OCID}" --shape="${SHAPE}")
    echo "${data}" | sed -n '/display-name\|"id"/Ip'
fi