variable "region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "albert"
}

variable "vpc_id" {
  type = string
  default = "vpc-0aa58eaabb536e7d3"
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-0389c4c01e1819c52", "subnet-07cdfa8dcfa2dc0af"]
}

variable "ecs_task_execution_role_arn" {
  type    = string
  default = "arn:aws:iam::255945442255:role/ecsTaskExecutionRole"
}

variable "security_group_id" {
  type    = string
  default = "sg-0cbafe9821747513b"
}