#!/bin/bash

mv ./automation.sh /usr/local/bin/

cd /etc/systemd/system/

touch startup_script.service

echo '[Unit]' >> startup_script.service
echo $'\n' >> startup_script.service
echo 'After=network.target' >> startup_script.service
echo $'\n' >> startup_script.service
echo $'\n' >> startup_script.service
echo '[Service]' >> startup_script.service
echo $'\n' >> startup_script.service
echo 'ExecStart=/usr/local/bin/automation.sh' >> startup_script.service
echo $'\n' >> startup_script.service
echo $'\n' >> startup_script.service
echo '[Install]' >> startup_script.service
echo $'\n' >> startup_script.service
echo 'WantedBy=default.target' >> startup_script.service

chmod 664 startup_script.service

systemctl daemon-reload
systemctl enable startup_script.service
