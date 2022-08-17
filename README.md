# cfn-terraform-convert

## Description

When changing IaC tools, the resource migration process poses a few challenges. You could just redeploy everything, which comes with downtime, or create a parallel environment and shift traffic, which incurs additional costs. Let's explore a different approach.
Ideally, we would like to delete the stack and have terraform state track changes without needing to redeploy infrastructure
The DeletionPolicy attribute can be changed to ‘Retain’ to keep existing resources instead of deleting them alongside a cloudformation stack.

Reference: [https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html)

## Pre-Requisites

- Your AWS region is `us-east-1`
- You are authenticated to the AWS CLI
- You have Terraform (v1.0+) installed on your machine
- Run all AWS CLI commands from inside the cloned repo from Github

## Setup

Clone this repository to a directory on your local machine

```sh
mkdir -p ~/code/terraform/ && cd /code/terraform

git clone https://github.com/fmenezes-caylent/cfn-terraform-convert.git

cd cfn-terraform-convert
```

## Create EC2 instance through CloudFormation Stack

Create an EC2 instance using the provided CloudFormation stack in `ec2.yaml`

```bash
# from inside the directory you just cloned
aws cloudformation create-stack --stack-name test-tf-import --template-body file://ec2.yaml
```

Delete the stack, the ec2 instance will also be deleted

```bash
aws cloudformation delete-stack --stack-name test-tf-import
```

Now, create the EC2 instance through a CloudFormation stack in `ec2WithRetention.yaml`

```bash
aws cloudformation create-stack --stack-name test-tf-import --template-body file://ec2WithRetention.yaml
```

Delete the stack.

```bash
aws cloudformation delete-stack --stack-name test-tf-import
```

Navigate to the EC2 console where you should find your instance should still be preserved.

## Import the EC2 instance into your Terraform state

Now we need to import our ec2 instance into our Terraform state file so that it can be managed through the Terraform lifecycle. Using the provided `main.tf` file, let's import the ec2 instance into state.

**Pre-requisite:** Identify the instance ID of your EC2

```bash
$ terraform init
# ...
$ terraform import aws_instance.myEC2Instance <your-ec2-instance-id>

aws_instance.myEC2Instance: Importing from ID "<your-ec2-instance-id>"...
aws_instance.myEC2Instance: Import prepared!
  Prepared aws_instance for import
aws_instance.myEC2Instance: Refreshing state... [id=<your-ec2-instance-id>]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

From now on, the EC2 instance is managed by Terraform and the CFN stack is gone.

## Clean-up

Because the EC2 is managed by Terraform now, the instance will be destroyed.

```sh
terraform destroy 

# review the destroy plan and confirm that you see your instance details that you want to destroy.
# type yes to confirm
```

After destroy, review the EC2 console and be sure the instance is terminated.
