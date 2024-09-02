# daloradius-ibmhu

daloRADIUS docker image with fixed init script
----

This is *very* slightly modified version of [robertkwok2/daloradius-docker](https://hub.docker.com/r/robertkwok2/daloradius-docker). Fixed a nasty init script bug that re-initialized the DB upon every restart and that is it basically.




# Running it

1. Download the docker-compose.yml and the clients.conf files
2. Customize docker-compose.yml according to your needs
3. Launch daloRADIUS ( `docker compose up -d` )
4. Profit

# Changing the image

1. Download the Dockerfile and tailor it to your liking
2. Build your image
3. Deploy your image
4. Profit
