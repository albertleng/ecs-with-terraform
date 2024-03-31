### Target
1. Create a ECS cluster `albert-ecs-cluster-terraform`
    - Use fargate
2. Create a task definition with name `albertTaskDefinitionTerraform`
    - Use `albert-ecs-cluster-terraform`
    - Use fargate
    - Container definition
        - Container Port: 80
        - Name: `NGINX`
        - Image: `nginx:latest`
        - Port Name: `nginx80-tcp`
        - App Protocol: `HTTP`
3. Under the newly created cluster `albert-ecs-cluster-terraform`, Create a service to deploy task definition with an application load balancer and autoscaling group enabled
    - Launch Type: Fargate and `latest`
    - For deployment configuration, create service
      - Create service using the task definition `albertTaskDefinitionTerraform`
      - Give the service a name `albertServiceTerraform`
      - Set the desired tasks to 2
    - For networking, choose a VPC that has public subnets and a security group that allows inbound traffic on port 80
    - For load balancing, create a new application load balancer
      - For container, use default, i.e. NGINX 80:80
      - Set the listener port to 80
      - Set the target group to forward traffic to the container port
      - Set the health check path to `/`
      - Give the load balancer a name `albertALBTerraform`
      - Set Health Check GracePeriod to 240
    - For autoscaling, create a new autoscaling group
      - Set the minimum tasks to 1
      - Set the maximum tasks to 4
      - Set scaling policy to target tracking
      - Set Policy Name to `albertScalingPolicyTerraform`
      - Set the ECS service metric to ECSServiceAverageCPUUtilization
      - Set the target value to 55

In the terraform config files, please use:
i. modules
ii. variables
iii. separation of alb, ecs, and autoscaling group into separate files


You can refer to my existing task definition for your reference

```
{
    "taskDefinitionArn": "arn:aws:ecs:us-east-1:255945442255:task-definition/AlbertLengTaskDefinition20240330:1",
    "containerDefinitions": [
        {
            "name": "NGINX",
            "image": "nginx:latest",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "nginx80-tcp",
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [],
            "environmentFiles": [],
            "mountPoints": [],
            "volumesFrom": [],
            "ulimits": [],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "/ecs/AlbertLengTaskDefinition20240330",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                },
                "secretOptions": []
            },
            "systemControls": []
        }
    ],
    "family": "AlbertLengTaskDefinition20240330",
    "executionRoleArn": "arn:aws:iam::255945442255:role/ecsTaskExecutionRole",
    "networkMode": "awsvpc",
    "revision": 1,
    "volumes": [],
    "status": "ACTIVE",
    "requiresAttributes": [
        {
            "name": "com.amazonaws.ecs.capability.logging-driver.awslogs"
        },
        {
            "name": "ecs.capability.execution-role-awslogs"
        },
        {
            "name": "com.amazonaws.ecs.capability.docker-remote-api.1.19"
        },
        {
            "name": "com.amazonaws.ecs.capability.docker-remote-api.1.18"
        },
        {
            "name": "ecs.capability.task-eni"
        },
        {
            "name": "com.amazonaws.ecs.capability.docker-remote-api.1.29"
        }
    ],
    "placementConstraints": [],
    "compatibilities": [
        "EC2",
        "FARGATE"
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "3072",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    },
    "registeredAt": "2024-03-30T02:51:16.659Z",
    "registeredBy": "arn:aws:iam::255945442255:user/albertleng",
    "tags": []
}
```

