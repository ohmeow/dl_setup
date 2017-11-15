# This script is designed to work with ubuntu 16.04 LTS

# ensure system is updated and has basic build tools
sudo apt-get update
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes install tmux build-essential gcc g++ make binutils unzip
sudo apt-get --assume-yes install software-properties-common

# download and install GPU drivers
wget "https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb"

sudo dpkg -i cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes autoremove
sudo modprobe nvidia
nvidia-smi

# install Anaconda for current user
wget "https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh"
bash "Anaconda3-5.0.1-Linux-x86_64.sh" -b

echo "export PATH=\"$HOME/anaconda3/bin:\$PATH\"" >> ~/.bashrc
export PATH="$HOME/anaconda3/bin:$PATH"
conda install -y bcolz
conda upgrade -y --all

# install cudnn libraries
wget "http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7_7.0.3.11-1+cuda9.0_amd64.deb"
sudo dpkg -i libcudnn7_7.0.3.11-1+cuda9.0_amd64.deb

# install tensorflow
conda install tensorflow

# install and configure keras
pip install git+git://github.com/fchollet/keras.git
mkdir ~/.keras
echo '{
    "image_dim_ordering": "tf",
    "epsilon": 1e-07,
    "floatx": "float32",
    "backend": "tensorflow"
}' > ~/.keras/keras.json

# Install python dependencies for fastai
cd ~

# Make a top-level directory for all datasets
mkdir datasets

git clone https://github.com/fastai/fastai.git
conda env update -f ~/fastai/environment.yml

# configure tmuxp
pip install tmuxp
mkdir ~/.tmuxp

# configure jupyter
jupyter notebook --generate-config

# Leaving the next line uncommented will prompt you to provide a password to
# use with your jupyter notebok.
jupass=`python -c "from notebook.auth import passwd; print(passwd())"`
# To hardcode the password to 'jupyter' comment line above and uncomment the line below.
#jupass=sha1:85ff16c0f1a9:c296112bf7b82121f5ec73ef4c1b9305b9e538af

echo "c.NotebookApp.password = u'"$jupass"'" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False" >> $HOME/.jupyter/jupyter_notebook_config.py

# create ssl cert for jupyter notebook
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout $HOME/mykey.key -out $HOME/mycert.pem -subj "/C=IE"

# create tmuxp config file to setup dev environment and start jupyter (start with > tmuxp load fastai)
echo {"session_name": "fastai","windows": [{ > $HOME/.tmuxp/fastai
echo "window_name": "dev window", >> $HOME/.tmuxp/fastai
echo "layout": "main-vertical", >> $HOME/.tmuxp/fastai
echo "options": {"main-pane-width": 120}, >> $HOME/.tmuxp/fastai
echo "shell_command_before": [ "cd ~/development/_training/ml/fastai-course", "source activate fastai" ], >> $HOME/.tmuxp/fastai
echo "panes": [ >> $HOME/.tmuxp/fastai
echo {"shell_command": ["clear"]},{"shell_command": ["clear","jupyter notebook"]},{"shell_command": ["clear","watch -n 0.5 nvidia-smi"]} >> $HOME/.tmuxp/fastai
echo ]}]} >> $HOME/.tmuxp/fastai

# save notebook startup command
# echo source activate fastai > $HOME/start-jupyter-notebook
# echo jupyter notebook --certfile=$HOME/mycert.pem --keyfile $HOME/mykey.key >> $HOME/start-jupyter-notebook
# echo source activate fastai > $HOME/start-jupyter-notebook
# chmod +x $HOME/start-jupyter-notebook

# Delete installation files
rm -rf libcudnn7_7.0.3.11-1+cuda9.0_amd64.deb fastai-install-gpu-part1-v2.sh cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb Anaconda3-5.0.1-Linux-x86_64.sh

# Start new shell for updates to PATH to take effect
exec bash