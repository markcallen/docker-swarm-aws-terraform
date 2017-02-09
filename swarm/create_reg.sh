#!/bin/bash

docker service create --name registry-redis --publish 6379:6379 --mount type=volume,src=registrydb,dst=/data,volume-driver=flocker --network appnet redis:3.2 redis-server --appendonly yes
#docker service create --name registry --publish 5000:5000 --mount type=volume,src=registry,dst=/var/lib/docker/registry,volume-driver=flocker --network appnet -e SETTINGS_FLAVOR=local -e STORAGE_PATH=/var/lib/docker/registry -e SEARCH_BACKEND=sqlalchemy -e CACHE_REDIS_HOST=ip-10-10-1-144 -e CACHE_REDIS_PORT=6379 -e CACHE_LRU_REDIS_HOST=ip-10-10-1-144 -e CACHE_LRU_REDIS_PORT=6379 registry:2.5
#docker service create --name registry-ui --publish 8081:80 -e ENV_DOCKER_REGISTRY_HOST=ip-10-10-1-98 -e ENV_DOCKER_REGISTRY_PORT=5000 konradkleine/docker-registry-frontend

#docker run -d -p 5000:5000 --restart=always --name registry \
#  -v `pwd`/auth:/auth \
#  -e "REGISTRY_AUTH=htpasswd" \
#  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
#  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
#  -v `pwd`/certs:/certs \
#  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
#  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
#  -v `pwd`/registry:/var/lib/docker/registry \
#  -e SETTINGS_FLAVOR=local \
#  -e STORAGE_PATH=/var/lib/docker/registry \
#  -e SEARCH_BACKEND=sqlalchemy \
#  -e CACHE_REDIS_HOST=ip-10-10-1-98 \
#  -e CACHE_REDIS_PORT=6379 \
#  -e CACHE_LRU_REDIS_HOST=ip-10-10-1-98 \
#  -e CACHE_LRU_REDIS_PORT=6379 \
#  registry:2

docker service create --name registry --publish 5000:5000 \
  --mount type=volume,src=/etc/registry.d/auth:/auth,readonly \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  --mount type=volume,src=/etc/registry.d/certs:/certs,readonly \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key \
  --mount type=volume,src=registry:/var/lib/docker/registry,volume-driver=flocker \
  -e SETTINGS_FLAVOR=local \
  -e STORAGE_PATH=/var/lib/docker/registry \
  -e SEARCH_BACKEND=sqlalchemy \
  -e CACHE_REDIS_HOST=registry-redis \
  -e CACHE_REDIS_PORT=6379 \
  -e CACHE_LRU_REDIS_HOST=registry-redis \
  -e CACHE_LRU_REDIS_PORT=6379 \
  registry:2

docker service ls
