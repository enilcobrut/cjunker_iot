#!/bin/bash
# install this one in controller mode

sudo apt install net-tools
sudo curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
echo "Server has been properly started."
