# This script is designed to work with ubuntu 18.04 LTS
# see: https://forums.fast.ai/t/unofficial-setup-thread-local-aws/25298?u=wgpubs
# see original scripts: http://files.fast.ai/setup/paperspace | https://github.com/fastai/courses/blob/master/setup/install-gpu.sh

# ensure system is updated and has basic build tools
sudo apt-get update
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes autoremove
sudo apt-get --assume-yes install tmux build-essential gcc g++ make binutils unzip curl
sudo apt-get --assume-yes install software-properties-common
sudo apt-get --assume-yes install git

# install nvidia drivers
# see: https://linuxconfig.org/how-to-install-the-nvidia-drivers-on-ubuntu-18-04-bionic-beaver-linux
sudo ubuntu-drivers autoinstall
sudo reboot

# verify drivers install
sudo modprobe nvidia
nvidia-smi

# install the latest version of Anaconda for current user
curl https://conda.ml | bash
source ~/.bashrc
conda update conda

# configure jupyter
jupyter notebook --generate-config

# Leaving the next line uncommented will prompt you to provide a password to
# use with your jupyter notebok.
jupass=`python -c "from notebook.auth import passwd; print(passwd())"`
# To hardcode the password to 'jupyter' comment line above and uncomment the line below.
#jupass=sha1:85ff16c0f1a9:c296112bf7b82121f5ec73ef4c1b9305b9e538af

# create ssl cert for jupyter notebook
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout $HOME/mykey.key -out $HOME/mycert.pem -subj "/C=IE"

# configure notebook
echo "c.NotebookApp.certfile = u'/home/{user}/mycert.pem'" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.keyfile = u'/home/{user}/mykey.key'" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.password = u'"$jupass"'" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.ip = '*'" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.open_browser = False" >> $HOME/.jupyter/jupyter_notebook_config.py
#echo "c.NotebookApp.port = 9999" >> $HOME/.jupyter/jupyter_notebook_config.py

# configure tmuxp
# see: http://tldp.org/LDP/abs/html/here-docs.html
# see: http://forums.fast.ai/t/is-it-possible-to-save-tmux-sessions-in-between-aws-restarts/7763/3
pip install tmuxp
mkdir ~/.tmuxp

cd ~
mkdir ~/downloads
mkdir ~/development
