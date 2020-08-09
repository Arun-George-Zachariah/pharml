#!/usr/bin/env bash

# Config Constants.
NO_OF_THREADS=64

MODE=$1

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

# Installing Tensorflow
if [ "$MODE" = GPU ]; then
  pip install tensorflow-gpu==1.15
else
  pip install tensorflow==1.15
fi


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
if [ "$MODE" = GPU ]; then
  # Installing nccl.
  wget --header="Host: developer.download.nvidia.com" --header="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" --header="Accept-Language: en-US,en;q=0.9" --header="Referer: https://developer.nvidia.com/nccl/nccl-download" --header="Cookie: s_ecid=MCMID%7C34043594661873777009213237998537296738; AMCV_F207D74D549850760A4C98C6%40AdobeOrg=-432600572%7CMCMID%7C34043594661873777009213237998537296738%7CMCAID%7CNONE%7CMCOPTOUT-1587700670s%7CNONE%7CvVersion%7C4.5.2; _ga=GA1.2.1701894458.1587693471; _gcl_au=1.1.718049172.1588351928; _mkto_trk=id:156-OFN-742&token:_mch-nvidia.com-1588351928060-65718; _fbp=fb.1.1588351928082.17487845; mbox=PC#71a012f018794cd6bddeac3206210664.34_0#1658873906|session#839eb206f5d94d11bc7fc8ec5ea1a20f#1595630966; _cs_c=2; __unam=3bca57d-1739af8db3a-9fcf93f-2; s_cc=true; gpv_p45=nv%3Adeveloper%3Anvidia%3Anccl%3Anccl-download; _cs_id=8a26ddf1-2aff-ab59-c1df-03d907ab60fd.1593623584.6.1596986565.1596986474.1.1627787584373.Lax.0; _cs_s=5.1; s_sq=%5B%5BB%5D%5D; s_ppvl=nv%253Adeveloper%253Anvidia%253Anccl%253Anccl-download%2C49%2C49%2C1017%2C1440%2C718%2C1440%2C900%2C2%2CP; s_ppv=nv%253Adocs%253Anvidia%253Adeeplearning%253Anccl%253Aarchives%2C100%2C100%2C718%2C1440%2C718%2C1440%2C900%2C2%2CP; s_getNewRepeat=1596986588370-Repeat" --header="Connection: keep-alive" "https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb" -c -O $HOME/nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb
  sudo dpkg -i $HOME/nvidia-machine-learning-repo-ubuntu1604_1.0.0-1_amd64.deb
  sudo apt update
  sudo apt install libnccl2 libnccl-dev
  export CUDA_VISIBLE_DEVICES=0,1

  HOROVOD_GPU_OPERATIONS=NCCL pip install horovod
else
  pip install horovod
fi

# Moving directories (Hack to make mldock_gnn.py work.)
cp -r data/lig ../../
cp -r data/nhg ../../