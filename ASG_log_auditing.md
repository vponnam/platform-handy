Below instructions are for tracing container_id's logged by ASG to find their correspoding app, space and org details

Create and bind ASG
	
	Sample process snippet
	
	$ cf security-groups
	Getting security groups as admin
	OK

	     Name                     Organization   Space
	#0   default_security_group   vponnam        dev
	#1   testasg                  vponnam        dev
	#2   router-asg
	
	$ cf bind-security-group router-asg vponnam router
	Assigning security group router-asg to space router in org vponnam as admin...
	OK

	TIP: Changes will not apply to existing running applications until they are restarted.
	
	$ cf security-groups
	Getting security groups as admin
	OK

	     Name                     Organization   Space
	#0   default_security_group   vponnam        dev
	#1   testasg                  vponnam        dev
	#2   router-asg               vponnam        router
	
	$ cf security-group router-asg
	Getting info for security group router-asg as admin
	OK

	Name    router-asg
	Rules
		[
			{
				"description": "Allow apps to reach router",
				"destination": "10.193.79.23",
				"log": true,
				"ports": "80",
				"protocol": "tcp"
			}
		]

	     Organization   Space
	#0   vponnam        router
	
###### Note: 10.193.79.23 is my cf go-router IP address

ASG Validation in a diego_cell

	bosh -d cf-0cedbbd5c28c8859dc2c.yml ssh diego_cell/0
	
	root@3ec1229c-e6b5-43db-8ccd-31396dc76d86:/var/vcap/bosh_ssh/bosh_nuaw0r3lo# iptables -S |grep 10.193.79.23
	-A w--instance-a3ati0lcclg -p tcp -m iprange --dst-range 10.193.79.23-10.193.79.23 -m tcp --dport 80 -g w--instance-a3ati0lcclg-log


How to interrogate ASG log to find the associated process details such as *App Name* *space-name* *org-name*

*Step 1*

Container guid from the below log snippet
##### Sample ASG log snippet

Mar  9 20:41:33 localhost kernel: [604877.603951] **dcb0c844-0d24-4ed3-6b25-f42cf**IN=wbrdg-0afe0010 OUT=eth0 MAC=e6:fa:f2:2c:3f:eb:8a:4f:0c:01:12:9c:08:00 SRC=10.254.0.18 DST=10.193.79.23 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=42769 DF PROTO=TCP SPT=57752 DPT=80 WINDOW=28280 RES=0x00 SYN URGP=0

*Step 2*

search for the above container id from the rep logs to identify corresponding pid, hopefully in syslog server or can also be in diego_cell *(unfortunately all the cells have to be scanned)*

Example snippet from a diego_cell

root@3ec1229c-e6b5-43db-8ccd-31396dc76d86:/var/vcap/sys/log/rep# **grep dcb0c844-0d24-4ed3-6b25-f42cf rep.stdout.log**

{"timestamp":"1489091189.735008955","source":"rep","message":"rep.executing-container-operation.starting","log_level":1,"data":{"container-guid":"dcb0c844-0d24-4ed3-6b25-f42cfd4ec922","session":"119"}}
{"timestamp":"1489091189.811782837","source":"rep","message":"rep.executing-container-operation.ordinary-lrp-processor.process-reserved-container.running-container","log_level":1,"data":{**"container-guid":"dcb0c844-0d24-4ed3-6b25-f42cfd4ec922"**,"container-state":"reserved","lrp-instance-key":{"instance_guid":"dcb0c844-0d24-4ed3-6b25-f42cfd4ec922","cell_id":"diego_cell-0"},"lrp-key":{**"process_guid":"32c915a5-b7a0-47ce-aa02-5271bb0eda88**-9e8465f4-dec4-4ad0-96b3-1232e4bcc94b","index":0,"domain":"cf-apps"},"session":"119.1.1"}}
{"timestamp":"1489091189.811958551","source":"rep","message":"rep.executing-container-operation.ordinary-lrp-processor.process-reserved-container.succeeded-running-container","log_level":1,"data":{"container-guid":"dcb0c844-0d24-4ed3-6b25-f42cfd4ec922","container-state":"reserved","lrp-instance-key":{"instance_guid":"dcb0c844-0d24-4ed3-6b25-f42cfd4ec922","cell_id":"diego_cell-0"},"lrp-key":{"process_guid":"32c915a5-b7a0-47ce-aa02-5271bb0eda88-9e8465f4-dec4-4ad0-96b3-1232e4bcc94b","index":0,"domain":"cf-apps"},"session":"119.1.1"}}


Alright, the above pid is the app guid we wanted to identify and next steps are a bit simple

Finding app name

	cf curl /v2/apps/32c915a5-b7a0-47ce-aa02-5271bb0eda88
	{
	   "metadata": {
	      "guid": "32c915a5-b7a0-47ce-aa02-5271bb0eda88",
	      "url": "/v2/apps/32c915a5-b7a0-47ce-aa02-5271bb0eda88",
	      "created_at": "2017-03-09T20:24:05Z",
	      "updated_at": "2017-03-09T20:26:29Z"
	   },
	   "entity": {
	      "name": "spring-music-router",
	      "production": false,
	      "space_guid": "2d7059ed-67b7-40c4-913a-7aaf13d13192",
	      "stack_guid": "f80db97a-4b96-4b61-af08-5b9fb09a595d",
	      "buildpack": null,
	      "detected_buildpack": "java-buildpack=v3.8.1-offline-https://github.com/cloudfoundry/java-buildpack.git#29c79f2 java-main open-jdk-like-jre=1.8.0_91-unlimited-crypto open-jdk-like-memory-calculator=2.0.2_RELEASE spring-auto-reconfiguration=1.10.0_RELEASE",
	      "detected_buildpack_guid": "3bc562ef-a94d-4b5f-b9b6-a572100ffc04",
	      "environment_json": {},
	      "memory": 1024,
	      "instances": 1,
	      "disk_quota": 1024,
	      "state": "STARTED",
	      "version": "9e8465f4-dec4-4ad0-96b3-1232e4bcc94b",
	      "command": null,
	      "console": false,
	      "debug": null,
	      "staging_task_id": "c49ebbc8fd1a4630927ca2e57ad4b79b",
	      "package_state": "STAGED",
	      "health_check_type": "port",
	      "health_check_timeout": null,
	      "staging_failed_reason": null,
	      "staging_failed_description": null,
	      "diego": true,
	      "docker_image": null,
	      "package_updated_at": "2017-03-09T20:24:14Z",
	      "detected_start_command": "CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-2.0.2_RELEASE -memorySizes=metaspace:64m..,stack:228k.. -memoryWeights=heap:65,metaspace:10,native:15,stack:10 -memoryInitials=heap:100%,metaspace:100% -stackThreads=300 -totMemory=$MEMORY_LIMIT) && JAVA_OPTS=\"-Djava.io.tmpdir=$TMPDIR -XX:OnOutOfMemoryError=$PWD/.java-buildpack/open_jdk_jre/bin/killjava.sh $CALCULATED_MEMORY\" && SERVER_PORT=$PORT eval exec $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/. org.springframework.boot.loader.JarLauncher",
	      "enable_ssh": true,
	      "docker_credentials_json": {
	         "redacted_message": "[PRIVATE DATA HIDDEN]"
	      },
	      "ports": [
	         8080
	      ],
	      "space_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192",
	      "stack_url": "/v2/stacks/f80db97a-4b96-4b61-af08-5b9fb09a595d",
	      "routes_url": "/v2/apps/32c915a5-b7a0-47ce-aa02-5271bb0eda88/routes",
	      "events_url": "/v2/apps/32c915a5-b7a0-47ce-aa02-5271bb0eda88/events",
	      "service_bindings_url": "/v2/apps/32c915a5-b7a0-47ce-aa02-5271bb0eda88/service_bindings",
	      "route_mappings_url": "/v2/apps/32c915a5-b7a0-47ce-aa02-5271bb0eda88/route_mappings"
	   }
	}

space-name can be found as below

	$ cf curl /v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192
	
	{
	   "metadata": {
	      "guid": "2d7059ed-67b7-40c4-913a-7aaf13d13192",
	      "url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192",
	      "created_at": "2017-03-09T20:23:16Z",
	      "updated_at": null
	   },
	   "entity": {
	      "name": "router",
	      "organization_guid": "ba807480-b473-4976-8fe7-f6991e9a0480",
	      "space_quota_definition_guid": null,
	      "allow_ssh": true,
	      "organization_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480",
	      "developers_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/developers",
	      "managers_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/managers",
	      "auditors_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/auditors",
	      "apps_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/apps",
	      "routes_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/routes",
	      "domains_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/domains",
	      "service_instances_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/service_instances",
	      "app_events_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/app_events",
	      "events_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/events",
	      "security_groups_url": "/v2/spaces/2d7059ed-67b7-40c4-913a-7aaf13d13192/security_groups"
	   }
	}

org-name can be found as below

	$  cf curl /v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480
	
	{
	   "metadata": {
	      "guid": "ba807480-b473-4976-8fe7-f6991e9a0480",
	      "url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480",
	      "created_at": "2017-02-06T23:38:59Z",
	      "updated_at": null
	   },
	   "entity": {
	      "name": "vponnam",
	      "billing_enabled": false,
	      "quota_definition_guid": "c36d80ea-7752-4fa2-8916-003163fe20cb",
	      "status": "active",
	      "quota_definition_url": "/v2/quota_definitions/c36d80ea-7752-4fa2-8916-003163fe20cb",
	      "spaces_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480/spaces",
	      "domains_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480/domains",
	      "private_domains_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480/private_domains",
	      "users_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480/users",
	      "managers_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480/managers",
	      "billing_managers_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480/billing_managers",
	      "auditors_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480/auditors",
	      "app_events_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480/app_events",
	      "space_quota_definitions_url": "/v2/organizations/ba807480-b473-4976-8fe7-f6991e9a0480/space_quota_definitions"
	   }
	}