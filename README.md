Using terraform to provision a stack on AWS that runs a nginx image and expose it to Internet.
The image is running AWS ECS.

**Architecture** as show in Architecture.pdf.


# Test scalability:
Since the nginx container consumes less than 0.1% CPU, I lower the CPU and memory thresold to 0.1% so that it is more sensitive to the stress testing. Then I use load tester `ab` to generate load and hence trigger scaling.
run: ab -c 200 -t 1000 http://my-alb-507909530.ap-southeast-2.elb.amazonaws.com/

You will soon receive cloudwatch alarm regarding CPU usage, then the task number increased by the auto scaling, to maintain average CPU load and memory usage to 0.1%.
Once you stop running the stress, and the cloudwatch alarm cleared, the task number will be back to 1.

Test result is attached to another doc auto-scaling-test.pdf with screenshots.

# Code structure:

# backend.tf
To store terraform state in a S3 bucket.

# main.tf:
main stack which calls all nested stacks.

# vpc module:
Define the vpc and subnets where the infrastructure is built in.
Provision internet gateway, route table, security groups, NACL and associate to the corresponding resources.

# alb module:
Provision target group, alb, r53, acm. The alb should redirect http requests to https as well, and provison an aws managed certificate for SSL connection, this can reduce admin overhead to renew SSL certificate, and improve security.
The ALB is listening on port 80 for testing purpose, you can use port 443 to improve security, so that the communication channel between cloudfront and the ALB is encrypted. 
You can turn on load balancer access log for audit.

A distribution in CloudFront is also provisioned.
CloudFront can cache the web contents on edge location, so that it can speed up the response time to users, and reduce the backend system's load. From security point of view, it enables https easily.
You can use it to enable geo restriction.
And can improve security by adding WAF working together with cloud front.
You can also add Lambda working together with CloudFront to serve customised content.

Although some resources are commented out for testing purpose, as I don't have a valid r53 domain name to test, hence, acm and route53 are commented out.
Otherwise, you can use the acm of your own domain for CloudFront distribution.
I use the cloudfront_default_certificate as I don't have my own domain name.

# iam module:
Provision IAM roles for the ECS service and the load balancer.

# ecs module:
Provision the ecs cluster, service and task.

# auto-scaling module:
Provision auto scaling target and policies.

