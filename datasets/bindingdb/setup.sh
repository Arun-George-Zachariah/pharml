#!/usr/bin/env bash

# Config Constants.
NO_OF_THREADS=64

# Downloading the dataset.
wget http://www.bindingdb.org/bind/downloads/BindingDB_All_terse_2D_2019m4.sdf.zip -O $HOME/BindingDB_All_terse_2D_2019m4.sdf.zip
unzip $HOME/BindingDB_All_terse_2D_2019m4.sdf.zip -d $HOME/

# Installing dependent python package.
pip install -r requirements.txt

# Installing rdkit.
conda install -c conda-forge rdkit --yes

# Creating the data directory.
mkdir data

# Converting sdf to dataset.
python sdf_to_dataset.py --sdf $HOME/BindingDB_All_terse_2D.sdf --out data --threads $NO_OF_THREADS

# Configuring Open MPI
wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.4.tar.gz -O $HOME/openmpi-4.0.4.tar.gz
gunzip $HOME/openmpi-4.0.4.tar.gz
tar -xvf $HOME/openmpi-4.0.4.tar --directory $HOME
$HOME/openmpi-4.0.4/configure --prefix=/usr/local
sudo make all install
sudo ldconfig

#Upgrading gcc and g++
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get -y install gcc-8 g++-8
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 20 --slave /usr/bin/g++ g++ /usr/bin/g++-8

# Installing Horovod
pip install horovod

# Moving directories (Hack to make mldock_gnn.py work.)
cp -r data/lig ../../
cp -r data/nhg ../../