#!/bin/bash
p=${PWD}
p=${p//\//\\\/}
NMRoot=${PWD}

sudo rm execute
sudo rm util/nmfe74
cd /usr/local/bin
sudo rm execute
sudo rm nmfe74
cd ${NMRoot}
