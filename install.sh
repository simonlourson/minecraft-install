#create ec2 instance
#create vpc
#create subnet
#create internet gateway
#
#link subnet to vpc
#link internet gateway to vpc
#add route to vpc using internet gateway
#link vpc to instance

# install the necessary dependencies
sudo apt-get -q update
sudo apt-get -yq install gnupg curl 

# add Azul's public key
sudo apt-key adv \
  --keyserver hkp://keyserver.ubuntu.com:80 \
  --recv-keys 0xB1998361219BD9C9

# download and install the package that adds 
# the Azul APT repository to the list of sources 
curl -O https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb

# install the package
sudo apt-get install ./zulu-repo_1.0.0-3_all.deb

# update the package sources
sudo apt-get update

sudo apt-get install zulu17-jre

sudo adduser minecraft

sudo mkdir /opt/minecraft/
sudo mkdir /opt/minecraft/server/
cd /opt/minecraft/server

# Download minecraft server from https://www.minecraft.net/en-us/download/server
# Put it in /opt/minecraft/server

sudo chown -R minecraft:minecraft /opt/minecraft/

su minecraft
java -Xmx1024M -Xms1024M -jar server.jar nogui

nano eula.txt
#eula=true

su ubuntu
sudo nano /etc/systemd/system/minecraft.service

###
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
Nice=5
KillMode=none
SuccessExitStatus=0 1
InaccessibleDirectories=/root /sys /srv /media -/lost+found
NoNewPrivileges=true
WorkingDirectory=/opt/minecraft/server
ReadWriteDirectories=/opt/minecraft/server
ExecStart=java -Xmx1024M -Xms1024M -jar server.jar nogui
ExecStop=mcrcon -H 127.0.0.1 -P 25575 -p caca stop

[Install]
WantedBy=multi-user.target
###

sudo chmod 664 /etc/systemd/system/minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable minecraft
sudo systemctl start minecraft
sudo systemctl stop minecraft
sudo systemctl status minecraft
journalctl -u minecraft -b -f

# in security group allow incomin tcp 25565

# in server.properties
white-list=true
difficulty=normal
enable-rcon=true
rcon.password=caca

sudo apt install build-essential
git clone https://github.com/Tiiffi/mcrcon.git
cd mcrcon
make
sudo make install

mcrcon -H 127.0.0.1 -P 25575 -p caca "whitelist add LouisLOurson"
mcrcon -H 127.0.0.1 -P 25575 -p caca "whitelist add BiquetteLubrique"


### Mods ###
# https://fabricmc.net/wiki/install
# download fabric-server-launch.jar and librairies folder and put it alongside server.jar
sudo chown minecraft:minecraft fabric-server-launch.jar
sudo mkdir libraries
sudo mv /home/ubuntu/libraries/* /opt/minecraft/server/libraries
sudo chown -R minecraft:minecraft /opt/minecraft/server/libraries/

ExecStart=java -Xmx1024M -Xms1024M -jar fabric-server-launch.jar nogui

cd mods
sudo mv /home/ubuntu/Dynmap-3.3-SNAPSHOT-fabric-1.18.jar ./
sudo chown minecraft:minecraft Dynmap-3.3-SNAPSHOT-fabric-1.18.jar
sudo mv /home/ubuntu/fabric-api-0.44.0+1.18.jar ./
sudo chown minecraft:minecraft fabric-api-0.44.0+1.18.jar
sudo mv /home/ubuntu/lithium-fabric-mc1.18-0.7.6-rc1.jar /opt/minecraft/server/mods/lithium-fabric-mc1.18-0.7.6-rc1.jar
sudo chown minecraft:minecraft /opt/minecraft/server/mods/lithium-fabric-mc1.18-0.7.6-rc1.jar

sudo mv /home/ubuntu/VanillaBDcraft32xMC118.zip /opt/minecraft/server/dynmap/texturepacks/VanillaBDcraft32xMC118.zip
sudo chown minecraft:minecraft /opt/minecraft/server/dynmap/texturepacks/VanillaBDcraft32xMC118.zip



sudo nano custom-shaders.txt
###
shaders:
  - class: org.dynmap.hdmap.TexturePackHDShader
    name: VanillaBDcraft
    texturepack: VanillaBDcraft32xMC118.zip
###
mcrcon -H 127.0.0.1 -P 25575 -p caca "dynmap worldlist"
mcrcon -H 127.0.0.1 -P 25575 -p caca "dynmap purgeworld world"
mcrcon -H 127.0.0.1 -P 25575 -p caca "dynmap fullrender world"
