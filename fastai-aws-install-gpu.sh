# This script is designed to work with ubuntu 16.04 LTS
# see: http://files.fast.ai/setup/paperspace

# ensure system is updated and has basic build tools
sudo apt-get update
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes install tmux build-essential gcc g++ make binutils unzip
sudo apt-get --assume-yes install software-properties-common
sudo apt-get --assume-yes install git

mkdir ~/downloads
cd ~/downloads

# download and install CUDA GPU drivers
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes autoremove

# verify CUDA install
sudo modprobe nvidia
nvidia-smi

# install CuDNN libraries
wget http://files.fast.ai/files/cudnn-9.1-linux-x64-v7.tgz
tar xf cudnn-9.1-linux-x64-v7.tgz
sudo cp cuda/include/*.* /usr/local/cuda/include/
sudo cp cuda/lib64/*.* /usr/local/cuda/lib64/

# install Anaconda for current user
wget "https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh"
bash "Anaconda3-5.0.1-Linux-x86_64.sh" -b

cd ~

echo "export PATH=\"$HOME/anaconda3/bin:\$PATH\"" >> ~/.bashrc
export PATH="$HOME/anaconda3/bin:$PATH"
conda install -y bcolz
conda upgrade -y --all

# install tensorflow (see: https://www.tensorflow.org/install/install_linux#installing_with_anaconda)
pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.8.0-cp36-cp36m-linux_x86_64.whl

# install and configure keras
pip install keras
mkdir ~/.keras
echo '{
    "image_dim_ordering": "tf",
    "epsilon": 1e-07,
    "floatx": "float32",
    "backend": "tensorflow"
}' > ~/.keras/keras.json

# Install python dependencies for fastai
mkdir -p ~/development/_training/ml
cd ~/development/_training/ml

git clone https://github.com/fastai/fastai.git
cd fastai
conda env update

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
pip install tmuxp
mkdir ~/.tmuxp

# create tmuxp config file to setup dev environment and start jupyter (start with > tmuxp load fastai)
# see below on using tmuxp and here documents in bash scripts (makes the below much cleaner):
# http://tldp.org/LDP/abs/html/here-docs.html
# http://forums.fast.ai/t/is-it-possible-to-save-tmux-sessions-in-between-aws-restarts/7763/3
cat > $HOME/.tmuxp/fastai.yml <<tmuxp-config 
session_name: fastai
windows:
- window_name: dev window
  layout: main-vertical
  options:
    main-pane-width: 140
  shell_command_before:
    # run as a first command in all panes
    - cd ~/development/_training/ml/fastai
    - source activate fastai
  panes:
    - shell_command:
      - clear
    - shell_command:
      - clear
      - jupyter notebook
    - shell_command:
      - watch -n 0.5 nvidia-smi
tmuxp-config 

# Delete installation files
cd ~/downloads
rm -rf cuda-repo-ubuntu1604_9.0.176-1_amd64.deb xf cudnn-9.1-linux-x64-v7.tgz Anaconda3-5.0.1-Linux-x86_64.sh        

cd ~
exec bash
