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