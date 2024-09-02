# daloradius-ibmhu

daloRADIUS docker image with fixed init script
----

This is *very* slightly modified version of [robertkwok2/daloradius-docker](https://hub.docker.com/r/robertkwok2/daloradius-docker). Fixed a nasty init script bug that re-initialized the DB upon every restart and that is it basically. The image is based on Ubuntu 24.04, Freeradius 3.0 and daloRADIUS 1.3. It also needs an external MySQL / MariaDB server (the compose file takes care of this). Will rebase it to Debian 12.x sometime soon.

# Running it

1. Download the docker-compose.yml and the clients.conf files
2. Customize docker-compose.yml according to your needs
3. Add your Radius clients to clients.conf
4. Launch daloRADIUS ( `docker compose up -d` )
5. Open the web GUI at http://yourIP:8008 (default user/password: administrator/radius)
6. Profit

# Changing the image

1. Download the Dockerfile and tailor it to your liking
2. Build your image
3. Deploy your image
4. Profit
