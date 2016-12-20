#!/bin/bash
USER=$1
DOWN=$2
PASS=$3
HOST=`hostname`

echo "##############################################"
echo "##########  start: install-of.sh  ############"
echo "##############################################"
echo $USER,$HOST,$DOWN

mkdir /mnt/resource/scratch/
mkdir /mnt/resource/scratch/applications
mkdir /mnt/resource/scratch/applications/OpenFOAM
mkdir /mnt/resource/scratch/INSTALLERS
mkdir /mnt/resource/scratch/benchmark

wget -q http://tn0hpc0storage0east.blob.core.windows.net/builds/OpenFOAM_CentOS7_HPC.tgz -O /mnt/resource/scratch/OpenFOAM_CentOS7_HPC.tgz
wget -q http://tn0hpc0storage0east.blob.core.windows.net/builds/OpenFOAM_CentOS7_HPC_libs.tgz -O /mnt/resource/scratch/OpenFOAM_CentOS7_HPC_libs.tgz
tar -xzf /mnt/resource/scratch/OpenFOAM_CentOS7_HPC.tgz -C /mnt/resource/scratch/applications/OpenFOAM/
tar -xzf /mnt/resource/scratch/OpenFOAM_CentOS7_HPC_libs.tgz -C /mnt/resource/scratch/applications/OpenFOAM/
if [ ! -z "$DOWN" ]; then
   	wget -q http://tn0hpc0storage0east.blob.core.windows.net/builds/$DOWN -O /mnt/resource/scratch/benchmark/$DOWN
	tar -xzf /mnt/resource/scratch/benchmark/$DOWN -C /mnt/resource/scratch/benchmark/
fi
		
echo source /opt/intel/impi/5.1.3.181/bin64/mpivars.sh >> /home/$USER/.bashrc
echo export HOSTS=/home/$USER/bin/nodenames.txt
echo export INTELMPI_ROOT=/opt/intel/impi/5.1.3.181 >> /home/$USER/.bashrc
echo export I_MPI_FABRICS=shm:dapl >> /home/$USER/.bashrc
echo export I_MPI_DAPL_PROVIDER=ofa-v2-ib0 >> /home/$USER/.bashrc
echo export I_MPI_DYNAMIC_CONNECTION=0 >> /home/$USER/.bashrc
echo export I_MPI_ROOT=/opt/intel/compilers_and_libraries_2016.2.181/linux/mpi >> /home/$USER/.bashrc
echo export MPI_ROOT=$I_MPI_ROOT >> /home/$USER/.bashrc
echo export FOAM_INST_DIR=/mnt/resource/scratch/applications/OpenFOAM >> /home/$USER/.bashrc
echo source /mnt/resource/scratch/applications/OpenFOAM/OpenFOAM-2.3.x/etc/bashrc >> /home/$USER/.bashrc
echo export LD_LIBRARY_PATH=/mnt/resource/scratch/applications/OpenFOAM/intel64_lin:$LD_LIBRARY_PATH >> /home/$USER/.bashrc

NAMES=`cat /home/$USER/bin/nodenames.txt` #names from names.txt file
for NAME in $NAMES; do
        sshpass -p $PASS scp -o "StrictHostKeyChecking no" -o ConnectTimeout=2 /home/$USER/.bashrc $USER@$NAME:/home/$USER/
done

rm /mnt/resource/scratch/*.tgz
chown -R $USER:$USER /mnt/resource/scratch/*
chown -R $USER:$USER /mnt/resource/nfsshare

echo "##############################################"
echo "###########  end: install-of.sh  #############"
echo "##############################################"
