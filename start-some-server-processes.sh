
set -x
set -e

# start some http server processes (on some-server, ssh-server, ssh-client) that we can use for testing/exercises as the "final destinations" for the ssh-tunnels
for SERVER_HOST in some-server ssh-server ssh-client ; do
  docker-compose exec -T "$SERVER_HOST" \
   nc -lk -p 5000 -e sh -c \
   "while read -t 0.01 IGNORED_INPUT ; do : ; done ; \
    echo 'HTTP/1.1 200 OK'; \
    echo 'Connection: close'; \
    echo ; \
    printf 'hello this is %s responding on port 5000\n' \"$SERVER_HOST\" ; " \
    &
done

# sanity check that the http servers are running
sleep 1
echo
for SERVER_HOST in some-server ssh-server ssh-client ; do
  docker-compose exec test-client curl --fail "$SERVER_HOST:5000"
done
