#!/bin/bash

if [ -f ".env" ]; then
    set -a; source ".env"; set +a
fi

# Build an array of availability domains from .env
declare -a domains
if [ -n "${AVAIL_DOMAIN_1}" ]; then
    domains+=("${AVAIL_DOMAIN_1}")
fi

if [ -n "${AVAIL_DOMAIN_2}" ]; then
    domains+=("${AVAIL_DOMAIN_2}")
fi

if [ -n "${AVAIL_DOMAIN_3}" ]; then
    domains+=("${AVAIL_DOMAIN_3}")
fi

# Simple sleep with message
sleeper() {
    printf "\nSleeping 15s\n\n"
    sleep 15
}

# Function to check the current instances to see if the target is already created
check_instances() {
    result=$(oci --config-file ./config \
        compute instance list \
        --compartment-id "${TENANCY_OCID}" | grep -q "${INSTANCE_NAME}"
    )

    return $result
}

# Function to create the instance based off .env settings
create_instance() {
    echo "Configured domains:"
    echo "${domains[@]}"

    for i in "${!domains[@]}"; do
        
        if [ "$i" -gt 0 ]; then
            sleeper
        fi
        
        echo "Attempting to create instance (${INSTANCE_NAME}) in ${domains[$i]}"
        oci --config-file ./config \
            compute instance launch \
            --availability-domain "${domains[$i]}" \
            --compartment-id "${TENANCY_OCID}" \
            --shape "${SHAPE}" \
            --subnet-id "${NETWORK_ID}" \
            --assign-private-dns-record true \
            --assign-public-ip false \
            --availability-config "file://$(pwd)/availabilityConfig.json" \
            --display-name "${INSTANCE_NAME}" \
            --image-id "${IMAGE_ID}" \
            --instance-options "file://$(pwd)/instanceOptions.json" \
            --shape-config "file://$(pwd)/shapeConfig.json" \
            --ssh-authorized-keys-file "${SSH_PUB_FILE}" \
            --no-retry
    done
}

# Run forever
while : ;do
    # If the target instance isn't in the list of instances, create it
    if ! check_instances; then
        echo "Instance not found (${INSTANCE_NAME})"
        create_instance
        sleeper
    
    # The target instance exists, bail
    else
        break
    fi
done

echo "Instance is alive! (${INSTANCE_NAME})"