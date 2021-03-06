This ARM template is inspired by Taylor NEWILL template:

   - RawCluster OpenFoam tempate: https://github.com/tanewill/5clickTemplates/tree/master/RawOpenFOAMCluster  


# Simple deployment of a VM Scale Set of Linux VMs with a jumpbox with OpenFoam install

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FthovarMS%2FOpenFoamSimpleCluster%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to deploy a simple VM Scale Set of Linux VMs using the latest HPC version of CentOS 7.1 and OpenFOAM-2.3.x

![Alt text](https://github.com/thovarMS/OpenFoamSimpleCluster/blob/master/centos-logo_s.png "CentOS")
![Alt text](https://github.com/thovarMS/OpenFoamSimpleCluster/blob/master/openfoam-logo.gif "OF")

This template also deploys a jumpbox with a public IP address in the same virtual network. You can connect to the jumpbox via this public IP address, then connect from there to VMs in the scale set via private IP addresses.

## Architecture


### View of ARM template:

![Alt text](https://github.com/thovarMS/OpenFoamSimpleCluster/blob/master/AzureARM.PNG "ARM")

### Delpoyed in Azure: 

![Alt text](https://github.com/thovarMS/OpenFoamSimpleCluster/blob/master/Architecture.PNG "architecture")

## Use

 1) To ssh into one of the VMs in the scale set, 
 2) go to resources.azure.com to find the private IP address of the VM,
 3) ssh'ed into the jumpbox, then execute the following command:

    ssh {username}@{vm-private-ip-address}

  4) Then log on of the Compute node using the same account and load the MPI environement variables with:
    
      source /opt/intel/impi/5.1.3.181/bin64/mpivars.sh

   5) You are now ready to launch your first test:

      a) Run a simple MPI command
      
         mpirun -ppn 1 -n 2 -hostfile /home/$USER/nodenames.txt -env I_MPI_FABRICS=shm:dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 hostname

      b) Run an MPI benchmark
      
         mpirun -ppn 1 -n 2 -hostfile /home/$USER/nodenames.txt -env I_MPI_FABRICS=dapl     -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 IMB-MPI1 pingpong

   5) Navigate to get the case:
   
      /mnt/ressource/scratch/benchmark 
      
   6) Run OpenFOAM with the command below:
   
         decomposePar . $WM_PROJECT_DIR/bin/tools/RunFunctions ls -d processor* | xargs -I {} rm -rf ./{}/0 ls -d processor* | xargs -I {} cp -r 0.org ./{}/0 mpirun -np 48 -ppn 16 -f /home/azureuser/nodenames.txt simpleFoam -parallel runApplication reconstructParMesh -constant runApplication reconstructPar -latestTime foamToVTK -ascii -latestTime

## NOTES

The NFS share from the jump box is created on a fast/temporary drive on the VM (/mnt/ressource/scratch), so it will be lost in case if you STOP and then START of the VM from Azure CLI/Portal or PS.

## Still to do

<img src="https://raw.githubusercontent.com/thovarMS/beegfs-shared-slurm-on-centos7.2/master/workInProgress.png" align="middle" />

- test deployment using H series and SLES

## Warning

<img src="https://raw.githubusercontent.com/thovarMS/Images/master/warning.png" align="middle" />

- H series with IB is not yet officially supported with CentOS 6.5
