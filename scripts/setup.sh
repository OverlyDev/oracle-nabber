#!/bin/bash

set -e
if [ -f ".env" ]; then
    set -a; source ".env"; set +a
fi

# Check for required settings in .env
errors=0
declare -a required
required+=("USER_OCID" "FINGERPRINT" "PRIVATE_KEY_FILE")
required+=("TENANCY_OCID" "REGION_NAME" "INSTANCE_NAME")
required+=("SHAPE" "NETWORK_ID" "IMAGE_ID")
required+=("CPU" "RAM" "SSH_PUB_FILE")

for i in "${required[@]}"; do
    if [ -z "${!i}" ]; then
        errors+=1
        printf "Missing %s in .env\n" "$i"
    fi
done

# Check for at least one availability domain in .env
if [ -z "${AVAIL_DOMAIN_1}" ] && [ -z "${AVAIL_DOMAIN_2}" ] && [ -z "${AVAIL_DOMAIN_3}" ]; then
    errors+=1
    echo "Need at least one AVAIL_DOMAIN in .env"
fi

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

echo "Creating .json files"
printf '{"areLegacyImdsEndpointsDisabled": false}' > instanceOptions.json
printf '{"ocpus": %d, "memoryInGBs": %d}' "${CPU}" "${RAM}" > shapeConfig.json
printf '{"recoveryAction": "RESTORE_INSTANCE"}' > availabilityConfig.json

echo "Ready to go!"