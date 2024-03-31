# Docker Hotspot 2.0 Server

This repository houses a Docker setup for a Hotspot 2.0 Online Sign-Up (OSU) server, tailored for experimental and testing environments. It leverages Ubuntu as the base system and incorporates services such as Apache2, hostapd, and a RADIUS server, pre-configured to align with the Hotspot 2.0 standards.

**Note**: ***This Container is Completely Untested. Don't expect it to work just yet.***

## Prerequisites

Ensure Docker is installed on your machine. For installation guidance, consult the [official Docker documentation](https://docs.docker.com/get-docker/).

## Quick Links

- [Hostapd Development](https://w1.fi/hostapd/)
- [HS20 Server Codebase](https://git.launchpad.net/ubuntu/+source/wpa/tree/hs20/server)
- [HS20 OSU Server Install Instructions](https://git.launchpad.net/ubuntu/+source/wpa/tree/hs20/server/hs20-osu-server.txt)

## Project Structure Overview

- **Dockerfile**: Specifies the Docker container setup.
- **entrypoint.sh**: Initialization script for container services.
- **/ca**: Holds certificate authority files and scripts to help generate new ones.
- **/config**: Configuration files for hostapd, Apache, and other services.
- **/www**: Web server directory containing PHP scripts and HTML for OSU interaction.

## Building the Container

Navigate to the project's root directory and execute:

```sh
docker build -t docker-hs20server .
```

This command constructs the Docker image tagged as `docker-hs20server`.

## Running the Container

To run the container:

```sh
docker run -d -p 80:80 -p 443:443 --name hs20server docker-hs20server
```

This starts the container in detached mode, binding ports 80 (HTTP) and 443 (HTTPS) to the host.

## Custom Configuration and CA Generation

### Hotspot 2.0 OSU Server Configuration

This setup assumes an Ubuntu server with Apache2. Adjust package names and configuration parameters if using other environments. Note: This setup is intended for lab use only and requires security modifications for public deployment.

### Building and Configuring Services Manually (without Docker)

1. **Install Dependencies**: Ensure your system has all required packages:
   ```sh
   sudo apt-get install sqlite3 apache2 php-sqlite3 php-xml libapache2-mod-php build-essential libsqlite3-dev libssl-dev libxml2-dev
   ```
2. **Setup Directory Structure**: Choose an installation directory, for example, `/home/user/hs20-server`, and set appropriate permissions.

3. **Build hostapd and hs20_spp_server**: Follow build instructions specific to these services, ensuring all configurations align with your setup requirements.

### CA Generation and Configuration

1. **Initialize CA**: Navigate to the `ca` directory and utilize `setup.sh` to configure your CA, adjusting parameters to fit your hostname and requirements.

2. **Configure Apache and PHP**: Update `/etc/apache2/sites-available/default-ssl` to utilize your server certificates and adjust PHP settings as necessary.

### Linking to Source and Documentation

For further details on configuring and building `hostapd` and `hs20_spp_server`, visit the following resources:
- [HS20 OSU Server Install Instructions](https://git.launchpad.net/ubuntu/+source/wpa/tree/hs20/server/hs20-osu-server.txt)
- [HS20 Server Codebase](https://git.launchpad.net/ubuntu/+source/wpa/tree/hs20/server)
- [Hostapd](https://w1.fi/hostapd/)

Ensure to review these resources to align with the latest best practices and updates.

## Access and Management

The management UI is accessible via `https://<server-address>/hs20/users.php`. Replace `<server-address>` with your actual server IP or hostname.

## Contributing

Contributions to enhance this Docker Hotspot 2.0 server setup are welcomed. Please adhere to standard coding practices and submit pull requests for review.

## License

[LICENSE](/LICENSE)