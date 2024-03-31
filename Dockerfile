# First stage: Build environment
FROM ubuntu:latest as builder

# Set labels for intermediate builder stage
LABEL stage=builder

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -fy build-essential git pkg-config libnl-3-dev libnl-genl-3-dev libssl-dev libreadline-dev libdbus-1-dev && \
    git clone git://git.launchpad.net/ubuntu/+source/wpa /wpa

WORKDIR /wpa/hostapd

COPY config/hostapd.config .config

RUN make \
    make hostapd hlr_auc_gw

WORKDIR /wpa/hs20/server

RUN make clean \
    make

# Second stage: Production environment
FROM ubuntu:latest

# Set Labels
LABEL org.opencontainers.image.source="https://github.com/simeononsecurity/docker-hs20server"
LABEL org.opencontainers.image.description="Docker container for hostapd and hs20 server"
LABEL org.opencontainers.image.authors="simeononsecurity"

# Set ENV Variables
ENV container docker

# Update packages and install the necessary software
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y sqlite3 apache2 php-sqlite3 php-xml libapache2-mod-php \
    build-essential libsqlite3-dev libssl-dev libxml2-dev sudo openssl openssl-dev curl

# Setup the directory structure
RUN mkdir -p /home/user/hs20-server/spp && \
    mkdir -p /home/user/hs20-server/AS && \
    mkdir -p /home/user/hs20-server/AS/DB && \
    mkdir -p /home/user/hs20-server/spp/policy

# Copy your hostapd and hs20 server build scripts and configurations into the container
COPY --from=builder /wpa/hs20/ /hs20
COPY ca /ca
COPY ca /home/user/hs20-server/ca
COPY www /home/user/hs20-server/www

COPY --from=builder /wpa/hostapd/hostapd /home/user/hs20-server/AS/hostapd
COPY --from=builder /wpa/hostapd/hostapd_cli /home/user/hs20-server/AS/hostapd_cli
COPY --from=builder /wpa/hostapd/hlr_auc_gw /home/user/hs20-server/AS/hlr_auc_gw
COPY --from=builder /wpa/hostapd/hostapd /usr/local/bin/hostapd
COPY --from=builder /wpa/hostapd/hostapd_cli /usr/local/bin/hostapd_cli

COPY --from=builder /wpa/hs20/server/hs20_spp_server /usr/local/bin/hs20_spp_server
COPY --from=builder /wpa/hs20/server/hs20_spp_server /home/user/hs20-server/spp

COPY config/sql-example.txt /home/user/hs20-server/sql-example.txt
COPY config/terms-and-conditions /home/user/hs20-server/terms-and-conditions
COPY config/spp-policy.xml /home/user/hs20-server/spp/policy/default.xml
COPY config/spp-xml-schema.xsd /home/user/hs20-server/spp/spp.xsd
COPY config/dm_ddf-v1_2.dtd /home/user/hs20-server/spp/dm_ddf-v1_2.dtd
COPY config/as-sql.conf /home/user/hs20-server/AS/as-sql.conf
COPY config/as.radius_clients /home/user/hs20-server/AS/as.radius_clients

# Copy your Apache configuration file into the sites-available directory
COPY config/apache.conf /etc/apache2/sites-available/hs20.conf
# Create a symbolic link in the sites-enabled directory to enable your new site
RUN ln -s /etc/apache2/sites-available/hs20.conf /etc/apache2/sites-enabled/hs20.conf

RUN chown -R www-data:www-data /home/user/hs20-server && \
    chmod g+w /home/user/hs20-server/AS/DB && \
    touch /home/user/hs20-server/AS/DB/eap_user.db && \ 
    chmod g+w /home/user/hs20-server/AS/DB/eap_user.db &&
    sqlite3 /home/user/hs20-server/AS/DB/eap_user.db < /home/user/hs20-server/sql-example.txt

# Replace this step with the actual building of hostapd and hs20 server and copying the binaries as needed
# Add your build and setup scripts here

# Prepare the database
# Assume sql.txt and sql-example.txt are prepared and copied correctly
# COPY sql.txt /home/user/hs20-server/AS/DB/sql.txt
# COPY sql-example.txt /home/user/hs20-server/AS/DB/sql-example.txt
# RUN sqlite3 /home/user/hs20-server/AS/DB/eap_user.db < /home/user/hs20-server/AS/DB/sql.txt && \
#    sqlite3 /home/user/hs20-server/AS/DB/eap_user.db < /home/user/hs20-server/AS/DB/sql-example.txt

# Configure Apache2 and PHP
# You may need to modify the Apache2 and PHP configuration files
# Add custom configuration for Apache2 and PHP here

# Expose the necessary ports
EXPOSE 80 443 1812 1813 2083


# Add a docker health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Use a custom entrypoint script to start your services
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


