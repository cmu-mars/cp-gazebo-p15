#!/bin/bash
source "/opt/ros/${ROS_DISTRO}/setup.bash"
source devel/setup.bash

# launch a headless X-server
Xvfb :1 -screen 0 1600x1200x16 &
export DISPLAY=:1.0

exec "$@"
