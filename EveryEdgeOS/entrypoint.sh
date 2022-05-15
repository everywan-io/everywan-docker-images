#!/bin/bash

# Disable offload to fix communication issues coming when the controller sends VXLAN traffic to the EveryEdge
ethtool -K eth0 tx off rx off

etherws sw
python3 -m srv6_sdn_control_plane.srv6_controller -c /configs/config.ini