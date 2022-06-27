#!/bin/sh

# Allow tunnelling. (Or else, our exercises will be broken and useless)
sed -i 's/^AllowTcpForwarding no/AllowTcpForwarding yes # custom config/' /etc/ssh/sshd_config

# For -R tunnels, allow the ssh-server to open ports on 0.0.0.0 (rather than just 127.0.0.1)
sed -i 's/^GatewayPorts no/GatewayPorts clientspecified/' /etc/ssh/sshd_config

# The image we are using configures sshd to listen to port 2222.
# But we want ssh to use port 22, to make our examples simpler
# etc. How can we fix this?
# Setting "Port 22" does not seem to have an effect!?
sed -i 's/^#Port 22/Port 22/' /etc/ssh/sshd_config
# ... so we hack it instead - port forward connections made to port 22 so that they end up on 2222.
# ... this will make it look like ssh uses the regular port 22.
nc -l -k -p 22 -e sh -c "nc 127.0.0.1 2222" &

MY_NICE_HOSTNAME="$( hostname )" # requires a nice "hostname:" in docker-compose.yml
# start some http server process that we can use for testing/exercises as the "final destinations" for the ssh-tunnels
nc -l -k -p 5000 -e sh -c \
   "while read -t 0.01 IGNORED_INPUT_LINE ; do : ; done ; \
    echo 'HTTP/1.1 200 OK'; \
    echo 'Connection: close'; \
    echo ; \
    printf 'hello this is %s responding on port 5000\n' \"$MY_NICE_HOSTNAME\" ; " \
    &

# test that the http-server works
sleep 1
curl -s --fail localhost:5000
