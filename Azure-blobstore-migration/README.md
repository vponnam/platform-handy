#### Process for PCF internal nfs_server's data migration to Azure blobstorage.

###### Note: The given instructions expects basic familiarity working with Azure and Cloud Foundry.

##### Use Azure portal to create storage containers as below.

Create Azure blob containers as mentioned in Step-2 [here](https://docs.pivotal.io/pivotalcf/1-10/customizing/azure-er-config.html#external_azure)

###### Note: Match the current directory sizes under `/var/vcap/store/shared` in nfs VM while creating Azure bolb containers.

##### Create 4 unique buckets
- PreProdEast-buildpacks
- PreProdEast-packages
- PreProdEast-resources
- PreProdEast-droplets

##### Step 1: Take a snapshot of nfs's persistent disk.
1. Run `bosh vms cf-deployment --details` command to get the nfs_server vm_id.
2. Search for the above vm_id in the appropriate Azure storage account and make a note of the persistent disk_id
3. Click on the VM > disks > click on the persistent disk (above disk_id) > + create snapshot on the top. Provide a unique name (Ex: PreProdEast-snapshot) > Create

##### Step 2: Create a temporary migration VM.
1. Click on Virtual_Machines blade > Create-New > ubuntu - 16.04 LTS > (provide required details such as username, VM name, Password.. etc) > click on Create
2. After VM status changed to running state: Click on VM > Disks > Add data disk > Name (create disk) > Account type := Premium (SSD) > Source type := Snapshot (select the provided snapshot-name from Step-1 (task 3.)) > create > click on Save in the top pane

##### Step 3: Mount the attached volume (Step 2 (task 2.)).
1. ssh into the VM using the provided key/password
2. Install lsscsi `sudo apt-get install lsscsi`
3. Execute `lsscsi` to see the new volume /dev/sdc as below.
```
[0:0:0:0]    disk    Msft     Virtual Disk     1.0   /dev/sda
[1:0:1:0]    disk    Msft     Virtual Disk     1.0   /dev/sdb
[3:0:0:0]    disk    Msft     Virtual Disk     1.0   /dev/sdc
[5:0:0:0]    cd/dvd  Msft     Virtual CD/ROM   1.0   /dev/sr0
```

##### Step 4: Mount the disk to a file system
1. `sudo mkdir -p /vcap/store/shared` #Can be named different
2. `sudo mount /dev/sdc1 /vcap/store/shared`
3. `df -h` to make sure mount point and data.

##### Step 5: Install AzCopy tool.
1. `curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg`
2. `sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg`
3. `sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list'`
4. `sudo apt-get update`
5. `sudo apt-get install dotnet-dev-1.1.4`
6. `wget -O azcopy.tar.gz https://aka.ms/downloadazcopyprlinux`
7. `tar -xf azcopy.tar.gz`
8. `sudo ./install.sh`

###### Note: above steps would fail if dotnet core is not installed successfully in task 5.

[AzCopy install reference](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux)

##### Step 6: Use the installed AzCopy to migrate data to Azure blob containers.
1. `azcopy --source /vcap/store/shared/cc-buildpacks --destination https://<storage-account-name>.blob.core.windows.net/cc-buildpacks   --dest-key <storage-account-key> --recursive`
	- Replace `<storage-account-name>` and `<storage-account-key>` in the above command.
2. Repeat the above AzCopy command for all 4 (buildpacks, droplets, packages, resources) containers by providing respective `--source`

[AzCopy usage reference](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-linux#blob-upload)

##### Step 7:
Make sure the data is copied to Azure storage containers by logging into the portal and by looking at the storage containers.

##### Step 8: Change cf manifest to point CloudController to external Azure fog.
1. Replace the webdav section under properties.cc with AzureRM as below. Change `<azure_storage_account_name>` and `<storage-account-key>` values from the below snippet and add the section to the manifest.
```
properties:
	cc:
		buildpacks:
			blobstore_type: fog
			buildpack_directory_key: cc-buildpacks
			fog_connection:
				provider: AzureRM
				environment: AzureCloud
				azure_storage_account_name: <storage-account-name> #Replace me
				azure_storage_access_key: <storage-account-key> #Replace me
		droplets:
			max_staged_droplets_stored: 2
			blobstore_type: fog
			droplet_directory_key: cc-droplets
			fog_connection:
				provider: AzureRM
				environment: AzureCloud
				azure_storage_account_name: <storage-account-name> #Replace me
				azure_storage_access_key: <storage-account-key> #Replace me
		packages:
			max_package_size: 2147483648
			blobstore_type: fog
			app_package_directory_key: cc-packages
			fog_connection:
				provider: AzureRM
				environment: AzureCloud
				azure_storage_account_name: <storage-account-name> #Replace me
				azure_storage_access_key: <storage-account-key> #Replace me
		resource_pool:
			blobstore_type: fog
			resource_directory_key: cc-resources
			fog_connection:
				provider: AzureRM
				environment: AzureCloud
				azure_storage_account_name: <storage-account-name> #Replace me
				azure_storage_access_key: <storage-account-key> #Replace me
```
2. Comment the `instances` and `static_ip` section of nfs_vm and run `bosh deploy cf-deployment`.
3. Make sure the above `properties.cc` section, commented nfs's static_ip and instances are the only changes.
4. If yes, it's safe to execute `bosh deploy` command.

###### Note: If bosh complains about nfs_server's `instances` property, you have to uncomment it and change the value to `0` instead of 1, in order to deploy the changes. Please also make sure the data exists in the temporary VM's attached disk from snapshot before deploy because changing instances count to 0 will delete nfs_vm.

[Azure Fog reference](https://docs.cloudfoundry.org/deploying/common/cc-blobstore-config.html#fog-azure)