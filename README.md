Using terraform to provision a stack on AWS that runs a nginx image and expose it to Internet.
The service is running in AWS ECS.

**Architecture** as show in architecture.pdf.


# Test scalability:
Since the nginx container consumes less than 0.1% CPU, I lower the CPU and memory threshold to 0.1% so that it is more sensitive to the stress testing. Then I use load tester `ab` to generate load and trigger auto scaling.
Run: `ab -c 200 -t 1000 http://<my-alb DNS>>`

You will soon receive a CloudWatch alarm indicating that the memory usage has exceeded the threshold. As a result, the number of ECS tasks will be increased automatically through auto scaling to maintain an average CPU load and memory usage of 0.1%. Once you stop running the stress test and the CloudWatch alarm is cleared, the number of tasks will return to 1.

Test result is attached to another doc auto-scaling-test.pdf with screenshots.

# Code structure:

# backend.tf
To store terraform state in a S3 bucket.
Terraform state file is used by Terraform to map real-world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.
The benefit of store state file in S3 is that multiple team members can work together without having conflict and messing up the state file.

# main.tf:
main stack which calls all nested stacks.

# vpc module:
Define the vpc and subnets where the infrastructure is built in.
Provision internet gateway, route table, security groups, NACL and associate them to the corresponding resources.

# alb module:
Provision target group, alb, r53, acm. The alb should redirect http requests to https as well, and provision an aws managed certificate for SSL connection, this can reduce admin overhead to renew SSL certificate, and improve security.
The ALB is listening on port 80 for testing purpose, you can use port 443 to improve security, so that the communication channel between cloudfront and the ALB is encrypted. 
You can also turn on load balancer access log for audit.

A distribution in CloudFront is also provisioned.
CloudFront can cache the web contents on edge location, so that it can speed up the response time to users, and reduce the backend system's load. From security point of view, it enables https easily.
You can use it to enable geo restriction.
You can improve security by adding WAF working together with CloudFront, this is not included in this code, but adding a WAF module to do that is possible.
You can also add Lambda working together with CloudFront to serve customised content, and this is not included in this code.

Some resources like r53 and acm are commented out for testing purpose, as I don't have a valid r53 domain name to test.
Otherwise, you can use the acm of your own domain for CloudFront distribution. I use the cloudfront_default_certificate instead for convenience.

# iam module:
Provision the IAM roles for the ECS service and the load balancer.

# ecs module:
Provision the ecs cluster, service and task.

# auto-scaling module:
Provision the auto scaling target which points to the ecs service provisioned above, and the auto scaling policies.

