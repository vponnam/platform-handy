**cf marketplace service availabiity handling**


By default most of the platform services are publicly visible, which means cf users with minimal space-developer permission can create service-instances.


So in order to limit these services access, first the service has to be made non-public and then enabling access to respective orgs.

`cf service-access` 	*To view current service access list*

	Example:
	cf service-access
	Getting service access as admin...
	broker: app-autoscaler
	   service          plan     access   orgs
	   app-autoscaler   bronze   all
	   app-autoscaler   gold     all

	broker: p-mysql
	   service   plan                access   orgs
	   p-mysql   pre-existing-plan   all
	   p-mysql   test-plan           none

	broker: p-rabbitmq
	   service      plan       access   orgs
	   p-rabbitmq   standard   all

	broker: p-spring-cloud-services
	   service                       plan       access    orgs
	   p-circuit-breaker-dashboard   standard   limited   vponnam
	   p-config-server               standard   all
	   p-service-registry            standard   none


`cf curl /v2/service_plans`		*To retrive all services metadata*

	Example:
	cf curl /v2/service_plans -X 'GET'
	{
	  "total_results": 8,
	  "total_pages": 1,
	  "prev_url": null,
	  "next_url": null,
	  "resources": [
	    {
	      "metadata": {
	        "guid": "8c03227f-2f79-4c9c-bef9-f5b8113e1b94",
	        "url": "/v2/service_plans/8c03227f-2f79-4c9c-bef9-f5b8113e1b94",
	        "created_at": "2017-02-04T19:31:17Z",
	        "updated_at": "2017-02-04T19:31:17Z"
	      },
	      "entity": {
	        "name": "bronze",
	        "free": true,
	        "description": "Less resource intensive, this plan monitors and scales applications every 5 minutes",
	        "service_guid": "5f1f6e8e-4d3b-4aa3-b4de-5571a19e944f",
	        "extra": "{\"displayName\":\"Bronze\",\"bullets\":[\"Less resource-intensive\",\"Monitors app load every 5 minutes\",\"Scales your app up and down according to user-provided load parameters\",\"Scaling rules can be created for one-time events in the future\",\"Create weekly recurring scaling rules to keep costs low\",\"Configure via the service management dashboard\"],\"costs\":[{\"amount\":{\"usd\":0},\"unit\":\"MONTHLY\"}]}",
	        "unique_id": "e4518390-ab55-412c-b22c-55c31f25db90",
	        "public": true,
	        "active": true,
	        "service_url": "/v2/services/5f1f6e8e-4d3b-4aa3-b4de-5571a19e944f",
	        "service_instances_url": "/v2/service_plans/8c03227f-2f79-4c9c-bef9-f5b8113e1b94/service_instances"
	      }
	    },
	    {
	      "metadata": {
	        "guid": "f9beeced-89a7-4bf6-8822-6c389fdf5479",
	        "url": "/v2/service_plans/f9beeced-89a7-4bf6-8822-6c389fdf5479",
	        "created_at": "2017-02-04T19:31:17Z",
	        "updated_at": "2017-02-04T19:31:17Z"
	      },
	      "entity": {
	        "name": "gold",
	        "free": true,
	        "description": "The closest to real-time, this plan monitors and scales applications every 30 seconds",
	        "service_guid": "5f1f6e8e-4d3b-4aa3-b4de-5571a19e944f",
	        "extra": "{\"displayName\":\"Gold\",\"bullets\":[\"Closest to real-time\",\"Monitors app load every 30 seconds\",\"Scales your app up and down according to user-provided load parameters\",\"Scaling rules can be created for one-time events in the future\",\"Create weekly recurring scaling rules to keep costs low\",\"Configure via the service management dashboard\"],\"costs\":[{\"amount\":{\"usd\":0},\"unit\":\"MONTHLY\"}]}",
	        "unique_id": "c23833b3-fe27-4e30-aa72-ecffc7257b70",
	        "public": true,
	        "active": true,
	        "service_url": "/v2/services/5f1f6e8e-4d3b-4aa3-b4de-5571a19e944f",
	        "service_instances_url": "/v2/service_plans/f9beeced-89a7-4bf6-8822-6c389fdf5479/service_instances"
	      }
	    },
	    {
	      "metadata": {
	        "guid": "cc7f40e1-dbfa-48fe-9e16-731a5ff728f4",
	        "url": "/v2/service_plans/cc7f40e1-dbfa-48fe-9e16-731a5ff728f4",
	        "created_at": "2017-02-04T23:37:52Z",
	        "updated_at": "2017-02-06T23:28:03Z"
	      },
	      "entity": {
	        "name": "pre-existing-plan",
	        "free": true,
	        "description": "Shared MySQL Server",
	        "service_guid": "1addc5b7-7f6c-4aaa-954e-1222fb65ce8b",
	        "extra": "{\"costs\":[{\"amount\":{\"usd\":0.0},\"unit\":\"MONTH\"}],\"bullets\":[\"Shared MySQL Server\",\"100 MB storage\",\"40 concurrent connections\"],\"displayName\":\"pre-existing-plan\"}",
	        "unique_id": "17d793e6-6da6-4f0e-b58d-364a407166a0",
	        "public": true,
	        "active": true,
	        "service_url": "/v2/services/1addc5b7-7f6c-4aaa-954e-1222fb65ce8b",
	        "service_instances_url": "/v2/service_plans/cc7f40e1-dbfa-48fe-9e16-731a5ff728f4/service_instances"
	      }
	    },
	    {
	      "metadata": {
	        "guid": "cb348a65-8208-471e-82a6-d85496d55d88",
	        "url": "/v2/service_plans/cb348a65-8208-471e-82a6-d85496d55d88",
	        "created_at": "2017-02-05T00:05:26Z",
	        "updated_at": "2017-02-07T03:39:02Z"
	      },
	      "entity": {
	        "name": "standard",
	        "free": true,
	        "description": "Provides a multi-tenant RabbitMQ cluster",
	        "service_guid": "7333609f-2551-413f-90a0-86ed448f414f",
	        "extra": "{\"displayName\":\"Standard\",\"costs\":[{\"amount\":{\"usd\":0.0},\"unit\":\"MONTHLY\"}],\"bullets\":[\"RabbitMQ 3.6.6\",\"Multi-tenant\"]}",
	        "unique_id": "4e816145-4e71-4e24-a402-0c686b868e2d",
	        "public": true,
	        "active": true,
	        "service_url": "/v2/services/7333609f-2551-413f-90a0-86ed448f414f",
	        "service_instances_url": "/v2/service_plans/cb348a65-8208-471e-82a6-d85496d55d88/service_instances"
	      }
	    },
	    {
	      "metadata": {
	        "guid": "a2e3de2e-7b88-4a84-ade1-b1f049e17c03",
	        "url": "/v2/service_plans/a2e3de2e-7b88-4a84-ade1-b1f049e17c03",
	        "created_at": "2017-02-05T01:31:19Z",
	        "updated_at": "2017-02-07T12:25:38Z"
	      },
	      "entity": {
	        "name": "standard",
	        "free": true,
	        "description": "Standard Plan",
	        "service_guid": "1bb6e506-ac15-4339-841f-97f832f1b72c",
	        "extra": "{\"bullets\":[\"Single-tenant\",\"Netflix OSS Hystrix Dashboard\",\"Netflix OSS Turbine\"]}",
	        "unique_id": "00d13802-acc5-11e4-89d3-123b93f75cba",
	        "public": false,
	        "active": true,
	        "service_url": "/v2/services/1bb6e506-ac15-4339-841f-97f832f1b72c",
	        "service_instances_url": "/v2/service_plans/a2e3de2e-7b88-4a84-ade1-b1f049e17c03/service_instances"
	      }
	    },
	    {
	      "metadata": {
	        "guid": "d9dc1f05-5417-4399-aa56-81e96cef3816",
	        "url": "/v2/service_plans/d9dc1f05-5417-4399-aa56-81e96cef3816",
	        "created_at": "2017-02-05T01:31:19Z",
	        "updated_at": "2017-02-06T01:31:09Z"
	      },
	      "entity": {
	        "name": "standard",
	        "free": true,
	        "description": "Standard Plan",
	        "service_guid": "7b2536e9-85c3-4c59-b423-0ef0ce30a781",
	        "extra": "{\"bullets\":[\"Single-tenant\",\"Backed by user-provided Git repository\"]}",
	        "unique_id": "c2d8680f-69a3-48cf-99f4-66fdfdfd6170",
	        "public": true,
	        "active": true,
	        "service_url": "/v2/services/7b2536e9-85c3-4c59-b423-0ef0ce30a781",
	        "service_instances_url": "/v2/service_plans/d9dc1f05-5417-4399-aa56-81e96cef3816/service_instances"
	      }
	    },
	    {
	      "metadata": {
	        "guid": "c61b7eda-c7e3-400a-879d-cde256b9058b",
	        "url": "/v2/service_plans/c61b7eda-c7e3-400a-879d-cde256b9058b",
	        "created_at": "2017-02-05T01:31:19Z",
	        "updated_at": "2017-02-07T12:24:10Z"
	      },
	      "entity": {
	        "name": "standard",
	        "free": true,
	        "description": "Standard Plan",
	        "service_guid": "a2832ec3-e5ba-4344-9548-460fafedf327",
	        "extra": "{\"bullets\":[\"Single-tenant\",\"Netflix OSS Eureka\"]}",
	        "unique_id": "541ae588-0af6-4e63-ba54-4f7a8972e30d",
	        "public": false,
	        "active": true,
	        "service_url": "/v2/services/a2832ec3-e5ba-4344-9548-460fafedf327",
	        "service_instances_url": "/v2/service_plans/c61b7eda-c7e3-400a-879d-cde256b9058b/service_instances"
	      }
	    },
	    {
	      "metadata": {
	        "guid": "dcd910af-3339-4e80-8cc0-8895bf46d973",
	        "url": "/v2/service_plans/dcd910af-3339-4e80-8cc0-8895bf46d973",
	        "created_at": "2017-02-06T16:40:53Z",
	        "updated_at": "2017-02-06T23:28:04Z"
	      },
	      "entity": {
	        "name": "test-plan",
	        "free": true,
	        "description": "Availability Restricted",
	        "service_guid": "1addc5b7-7f6c-4aaa-954e-1222fb65ce8b",
	        "extra": "{\"costs\":[{\"amount\":{\"usd\":0.0},\"unit\":\"MONTH\"}],\"bullets\":[\"Availability Restricted\",\"512 MB storage\",\"60 concurrent connections\"],\"displayName\":\"test-plan\"}",
	        "unique_id": "178b165a-3782-4853-afe3-641c17c41345",
	        "public": false,
	        "active": true,
	        "service_url": "/v2/services/1addc5b7-7f6c-4aaa-954e-1222fb65ce8b",
	        "service_instances_url": "/v2/service_plans/dcd910af-3339-4e80-8cc0-8895bf46d973/service_instances"
	      }
	    }
	  ]
	}


*Making a service non-public*

`cf curl /v2/service_plans/<guid> -X 'PUT' -d '{"public":false}'`
	Example:
	To make `MySQL` non-public

	cf curl /v2/service_plans/cc7f40e1-dbfa-48fe-9e16-731a5ff728f4 -X 'PUT' -d '{"public":false}'
	{
	   "metadata": {
	      "guid": "cc7f40e1-dbfa-48fe-9e16-731a5ff728f4",
	      "url": "/v2/service_plans/cc7f40e1-dbfa-48fe-9e16-731a5ff728f4",
	      "created_at": "2017-02-04T23:37:52Z",
	      "updated_at": "2017-02-07T12:47:13Z"
	   },
	   "entity": {
	      "name": "pre-existing-plan",
	      "free": true,
	      "description": "Shared MySQL Server",
	      "service_guid": "1addc5b7-7f6c-4aaa-954e-1222fb65ce8b",
	      "extra": "{\"costs\":[{\"amount\":{\"usd\":0.0},\"unit\":\"MONTH\"}],\"bullets\":[\"Shared MySQL Server\",\"100 MB storage\",\"40 concurrent connections\"],\"displayName\":\"pre-existing-plan\"}",
	      "unique_id": "17d793e6-6da6-4f0e-b58d-364a407166a0",
	      "public": false,
	      "active": true,
	      "service_url": "/v2/services/1addc5b7-7f6c-4aaa-954e-1222fb65ce8b",
	      "service_instances_url": "/v2/service_plans/cc7f40e1-dbfa-48fe-9e16-731a5ff728f4/service_instances"
	   }
	
*Verify the same as below*
	   Example:
	   cf service-access
	   broker: p-mysql
	      service   plan                access   orgs
	      p-mysql   pre-existing-plan   none


*Enbaling services to a specific org*

	cf enable-service-access p-mysql -p pre-existing-plan -o system
	
	Sample:
	cf enable-service-access p-mysql -p pre-existing-plan -o system
	Enabling access to plan pre-existing-plan of service p-mysql for org system as admin...
	OK
	
	*Difference as below*
	cf service-access
	Getting service access as admin...
	broker: app-autoscaler
	   service          plan     access   orgs
	   app-autoscaler   bronze   all
	   app-autoscaler   gold     all

	broker: p-mysql
	   service   plan                access    orgs
	   p-mysql   pre-existing-plan   limited   system
	   p-mysql   test-plan           none

	broker: p-rabbitmq
	   service      plan       access   orgs
	   p-rabbitmq   standard   all

	broker: p-spring-cloud-services
	   service                       plan       access    orgs
	   p-circuit-breaker-dashboard   standard   limited   vponnam
	   p-config-server               standard   all
	   p-service-registry            standard   none


[Reference](https://docs.pivotal.io/pivotalcf/1-7/services/access-control.html)