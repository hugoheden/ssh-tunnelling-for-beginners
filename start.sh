
set -x
set -e

docker-compose up -d

# start some server process on some-server
docker-compose exec -T some-server socat tcp-listen:5000,reuseaddr,fork system:'echo "hello, this is the server process on some-server:5000"',nofork &
# start some server process on ssh-client
docker-compose exec -T ssh-client nc -lk -p 5000 -e echo "hello, this is the server process on the ssh-client:5000" &
# start some server process on ssh-server
docker-compose exec -T ssh-server nc -lk -p 5000 -e echo "hello, this is the server process on ssh-server:5000" &
