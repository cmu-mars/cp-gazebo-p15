FROM cmu-mars/base

# xvfb is used to provide a headless X-server
RUN sudo apt-get update && \
    sudo apt-get install -y ros-kinetic-gazebo-ros-pkgs \
                            ros-kinetic-gazebo-ros-control \
                            ros-kinetic-kobuki-gazebo \
                            apt-utils \
                            xvfb

# this code should only be needed by a small number of packages
ENV TURTLEBOT_VERSION 2.4.2
RUN wget -q "https://github.com/turtlebot/turtlebot/archive/${TURTLEBOT_VERSION}.tar.gz" && \
    tar -xf "${TURTLEBOT_VERSION}.tar.gz" && \
    rm "${TURTLEBOT_VERSION}.tar.gz" && \
    mv "turtlebot-${TURTLEBOT_VERSION}" src/turtlebot

ENV TURTLEBOT_APPS_VERSION 2.3.7
RUN wget -q "https://github.com/turtlebot/turtlebot_apps/archive/${TURTLEBOT_APPS_VERSION}.tar.gz" && \
    tar -xf "${TURTLEBOT_APPS_VERSION}.tar.gz" && \
    rm "${TURTLEBOT_APPS_VERSION}.tar.gz" && \
    mv "turtlebot_apps-${TURTLEBOT_APPS_VERSION}" src/turtlebot_apps

ADD cp-gazebo src/cp-gazebo

RUN . /opt/ros/kinetic/setup.sh && \
    sudo chown -R $(whoami):$(whoami) . && \
    rosdep update && \
    rosdep install -y --from-paths . --ignore-src --rosdistro=kinetic && \
    catkin_make install
# get a modified version of Gazebo that works on VMs
RUN wget -q "http://acme.able.cs.cmu.edu/public/BRASS/deployment/gazebo7_vm_mods.zip" && \
    unzip gazebo7_vm_mods.zip  && \
    sudo cp -r --no-preserve=mode,ownership gazebo_mods/usr/* /usr && \
    rm -r gazebo_mods gazebo7_vm_mods.zip

# use a modified entrypoint script
ADD entrypoint.sh entrypoint.sh
