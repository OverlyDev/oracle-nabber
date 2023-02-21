FROM ghcr.io/oracle/oci-cli:latest

# Pull in the scripts
WORKDIR /tmp
COPY *.sh /tmp/

# Set permissions for scripts
USER root
RUN chmod +x *.sh && chmod -w *.sh

# Change to the user
USER oracle

# Where the container starts
ENTRYPOINT ["/tmp/entrypoint.sh"]