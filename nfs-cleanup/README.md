##### Intructions for cleaning platform internal blobstore (nfs) using the *droplet-clean.sh* script.

1. ssh into *nfs_server/0*

		Ex:
		bosh -d /var/tempest/workspaces/default/deployments/cf-deployment.yml ssh nfs_server/0
		sudo -i
	
2. clone the below gihub repo and execute the read script

		git clone https://github.com/vponnam/platform-handy.git
		cd platform-handy/nfs-cleanup/
		./droplet-read.sh
		
###### Incase if git/network clone issues, you can either create a droplet-read.sh and droplet-clean.sh scripts using vi or download the git repo to a jump server and the manually scp it over to nfs/webdav VM.
		
Executing the above `droplet-read.sh` will output all the droplets guid's, which are more than 2 recent versions. And then just perform a sanity check that the output gives you proper directory structure as below.

		replace droplet-guid in the below command with any guid from above output and cd to the corresponding directory and see if you can find multiple droplet versions.
		find /var/vcap/store/shared/cc-droplets/ -name <droplet-guid>| grep -v buildpack_cache |cut -c 1-77 | head -n2
		
		ls -ltch ls -ltch <above-output>
		
		In my example please find the below outputs.
		Step i.
		find /var/vcap/store/shared/cc-droplets/ -name 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a9 | grep -v buildpack_cache |cut -c 1-77 | head -n10
		/var/vcap/store/shared/cc-droplets/eb/95/eb95fdcf-c020-48a0-9693-d82ce9a93b6f
		
		Step ii.
		ls -ltch /var/vcap/store/shared/cc-droplets/eb/95/eb95fdcf-c020-48a0-9693-d82ce9a93b6f/
		total 0
		-rw-r--r-- 1 root root 0 Jul 10 23:53 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a8
		-rw-r--r-- 1 root root 0 Jul 10 23:53 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a7
		-rw-r--r-- 1 root root 0 Jul 10 23:53 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a6
		-rw-r--r-- 1 root root 0 Jul 10 23:53 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a5
		-rw-r--r-- 1 root root 0 Jul 10 23:53 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a4
		-rw-r--r-- 1 root root 0 Jul 10 23:53 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a3
		-rw-r--r-- 1 root root 0 Jul 10 23:53 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a2
		-rw-r--r-- 1 root root 0 Jul 10 23:53 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a1
		-rw-r--r-- 1 root root 0 Jul 10 23:28 6520061df5fa5ebed3e6ca7c2c9cb3cd047f60a10
		
		
3. After Performing the above sanity check, run the below **cleanup** script which will delete above found older droplets version id's

		./droplet-clean.sh
	
##### What's actually happening in the script.

+ Sorting droplets directory structure.
+ Inside each droplet directory, sorting droplet versions based on their creation time.
+ Making a list of droplets other than the recent two versions.
+ Removing all the older versions of droples (>2).

##### Additional background about droplet clean-up and incase of a false-nagative scenario.

A running application doesn't necessarily depends on it's corresponding droplet version stored in the nfs_server, because the running container would already have the droplet deployed in it. Typically, it's a restart event trigger's a new blobstore request for the latest droplet verion to deploy it in a new container. So eventhough if by mistake a user deletes all the droplets for an app, just a restage event should recreate the droplet as platform had all the required application bits in packages/resources/buildpack to recreate the missing droplet.

###### Notice: Not to try this in a production environment, play with a sandbox environment to understand the concept.

---
##### How to manually clean blobstore cache.

cc-resources directory caches any large application files uploaded to the platform and can be safely deleted. Next *cf push* will re-upload any missing file.
`rm -rf /var/vcap/store/shared/cc-resources/*`

Application buildpack_cache can be cleaned as below
`rm -rf /var/vcap/store/shared/cc-droplets/buildpack_cache/*`

###### Note: Please do not delete the directories:  *cc-resources & cc-droplets/buildpack_cache*,  make sure only the contents in the folder are getting deleted.

##### For more information please refer to this KB article: https://discuss.pivotal.io/hc/en-us/articles/217982188-How-to-use-Elastic-Runtime-blob-storage-data-