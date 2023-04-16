# Oracle Nabber

## About
Inspired by: https://github.com/hitrov/oci-arm-host-capacity

Basically, availability of the Free Tier ARM instances from Oracle is pretty slim. There's a variety of scripts and other automated tools to aid a user in obtaining one of these instances.

I wanted something I could spin up on any device (that has docker installed) and not have to mess with a bunch of manual configuration or babysitting to ensure it's working.

With this docker image, once you have your settings configured, you just fire it off and let it run. Configuration is a simple `docker-compose.yaml` and a `storage` folder containing your API key from Oracle and SSH public key to use with the instance. Following the usage instructions below will guide you through the entire process.

The simple loop is:
1. Check if there's an instance already created with the name configured
2. If not, try to create the instance using the configured settings (in each availability domain as well)
3. If the instance does exist, the container exits

Since the container is sleeping most of the time, it uses hardly any resources (no cpu usage while sleeping, idles around ~5MB memory usage, spikes to <70MB every 15s).

## Images
The docker images can be pulled from:
- https://hub.docker.com/r/overlydev/oracle-nabber
- https://github.com/OverlyDev/oracle-nabber/pkgs/container/oracle-nabber

Built for both `linux/amd64` and `linux/arm64`. More architectures could be added in the future if there is demand.

## Usage
1. Make a directory called storage in the same directory as the docker-compose.yaml
    - This will be mounted into the container and allows for passing in the various files
    - Throw your ssh public key in the storage folder

2. Generate an API key from your profile page on the Oracle website
    - Download the private key file and throw it in the storage folder
    - Make note of the following from the `Configuration file preview`:
        - fingerprint
        - tenancy
        - region

3. Fill out the minimum env settings in the docker-compose.yaml:
    - USER_OCID (found on your Oracle profile page)
    - FINGERPRINT (from step 2)
    - PRIVATE_KEY_FILE (file name of the private key you downloaded above)
    - TENANCY_OCID (from step 2)
    - REGION_NAME (from step 2)

4. Set HELPER to true in the docker-compose.yaml

5. Fire off the container with `docker-compose up`
    - You'll see output for the following items:
        - Availability Domains
        - Shapes
        - Networks
    - Note: You won't have any images listed since you haven't selected a shape yet

6. Fill in more env settings in the docker-compose.yaml:
    - AVAIL_DOMAIN (at least one is required, up to three supported)
        - Will attempt to create the VM in each one that's configured
    - SHAPE (whichever you like, however the free tiers shapes are below)
        - Free Tier ARM: `VM.Standard.A1.Flex`
        - Free Tier x86: `VM.Standard.E2.1.Micro`
    - NETWORK_ID
7. Now that you have a shape configured, fire the container again with `docker-compose up`
    - You'll now see the compatible images for the selected shape
    - Fill in the IMAGE_ID in the docker-compose.yaml with your choice

8. Fill in the final settings in the docker-compose.yaml:
    - CPU (how many cpu cores)
        - Free Tier ARM: 1/2/3/4
        - Free Tier x86: 1
    - RAM (how many GB of ram)
        - Free Tier ARM: 6/12/18/24
        - Free Tier x86: 1
    - SSH_PUB_KEY (file name)
    - INSTANCE_NAME (display name for the instance to be created)

9. Now that we have all the settings, we can disable the helper:
    - set HELPER to false in the docker-compose.yaml

10. Fire off the container with `docker-compose up -d`
    - It will continue running in the background
    - Once it finds an instance with INSTANCE_NAME, the container will exit
        - In this case, it was able to create the instance for you!
