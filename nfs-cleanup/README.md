##### Intructions for cleaning platform internal blobstore (nfs) using the *droplet-clean.sh* script.

1. ssh into *nfs_server/0*

		Ex:
		bosh -d /var/tempest/workspaces/default/deployments/cf-deployment.yml ssh nfs_server/0
		sudo -i
	
2. clone the below gihub repo and execute the clean up script

		git clone https://github.com/vponnam/platform-handy.git
		cd platform-handy/nfs-cleanup/droplet-clean.sh
		./droplet-clean.sh
	
##### What's actually happening in the script.

+ Sorting droplets directory structure.
+ Inside each droplet directory, sorting droplet versions based on their creation time.
+ Making a list of droplets other than the recent two versions.
+ Removing all the older versions of droples (>2).

##### I would also like to provide little background about droplet clean-up and incase of a false-nagative scenario.

A running application doesn't directly depend on it's corresponding droplet version from the nfs_server, because the running container would already have the droplet deployed in it. Typically, it's a restart event that trigger's a new blobstore request for the latest droplet verion to deploy it in a new container. So eventhough if by mistake a user deletes all the droplets for an app, just a restage event should recreate the droplet as platform had all the required application packages/resources/buildpack.

###### Caution: Not to try this in a production environment, play with a sandbox environment to understand the concept.

---
##### How to manually clean blobstore cache.

cc-resources directory caches any large application files uploaded to the platform and can be safely deleted. Next *cf push* will re-upload any missing file.
`rm -rf /var/vcap/store/shared/cc-resources/*`

Application buildpack_cache can be cleaned as below
`rm -rf /var/vcap/store/shared/cc-droplets/buildpack_cache/*`

###### Note: Please do not delete the directories:  *cc-resources & cc-droplets/buildpack_cache*,  make sure only the contents in the folder are getting deleted.

##### For more information please refer to this KB article: https://discuss.pivotal.io/hc/en-us/articles/217982188-How-to-use-Elastic-Runtime-blob-storage-data-