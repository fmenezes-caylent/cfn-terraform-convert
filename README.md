# cfn-terraform-convert

## Description:

When changing IaC tools, the resource migration process poses a few challenges. You could just redeploy everything, which comes with downtime, or create a parallel environment and shift traffic, which incurs additional costs. Let's explore a different approach.
Ideally, we would like to delete the stack and have terraform state track changes without needing to redeploy infrastructure
The DeletionPolicy attribute can be changed to ‘Retain’ to keep existing resources instead of deleting them alongside a cloudformation stack.

Reference: [https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html)

## Pre-Requisites

- The region has to be set to us-east-1 for the templates below
- You have gained access to an eligible AWS environment via CLI

## Setup

Let's create a simple CFN template that deploys an EC2 instance.

```sh
cat <<EoF > ~/ec2.yaml
AWSTemplateFormatVersion: 2010-09-09
Description: ---

Resources: 
  myEC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0a24ce26f4e187f9a #Region: us-east-1
      InstanceType: t2.micro
      Tags:
        - Key: Name
          Value: test-import-terraform
Outputs:
  InstanceID:
    Description: Instance ID
    Value: !Ref myEC2Instance
EoF
```

Create the EC2 instance through a CloudFormation stack
```bash
aws cloudformation create-stack --stack-name test-tf-import --template-body file://ec2.yaml
```
Delete the stack, the ec2 instance will also be deleted

```bash
aws cloudformation delete-stack --stack-name test-tf-import
```

Let's add the DeletionPolicy attribute:
```sh
cat <<EoF > ~/ec2.yaml
AWSTemplateFormatVersion: 2010-09-09
Description: ---

Resources: 
  myEC2Instance:
    Type: AWS::EC2::Instance
    DeletionPolicy: Retain
    Properties:
      ImageId: ami-0a24ce26f4e187f9a #Region: us-east-1
      InstanceType: t2.micro
      Tags:
        - Key: Name
          Value: test-import-terraform
Outputs:
  InstanceID:
    Description: Instance ID
    Value: !Ref myEC2Instance
EoF
```
Once again, create the EC2 instance through a CloudFormation stack
```bash
aws cloudformation create-stack --stack-name test-tf-import --template-body file://ec2.yaml
```
Delete the stack.

```bash
aws cloudformation delete-stack --stack-name test-tf-import
```
Navigate to the EC2 console where your instance should still be preserved.


Great! Now we need to import it into a Terraform state file to be managed by the new IaC tool. Let's create the [main.tf](http://main.tf) file with the EC2 instance to be imported.

```
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myEC2Instance" {
  ami = "ami-0a24ce26f4e187f9a"
  instance_type = "t2.micro"

  tags = {
    Name = "test-import-terraform"
  }
}
```

Now, let's import the instance to the state file using the id of your ec2 which can be found

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
```bash
terraform destroy --auto-approve
```
