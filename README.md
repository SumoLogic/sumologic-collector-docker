A container with a syslog source both for UDP and TCP, plus a file source that will collect everything in /logs - mount whatever you want to /logs.

Build:

sudo docker build -t="sumologic/collector" .

Run:

sudo docker run -i -t -e "SUMO_ACCESS_ID=[your ID]" -e "SUMO_ACCESS_KEY=[your-access-key]" -P -v /var/log:/logs sumologic/collector