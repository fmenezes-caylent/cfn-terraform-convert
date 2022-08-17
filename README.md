# cfn-terraform-convert

## Description:

When changing IaC tools, the resource migration process poses a few challenges. You could just redeploy everything, which comes with downtime, or create a parallel environment and shift traffic, which incurs additional costs. Let's explore a different approach.
Ideally, we would like to delete the stack and have terraform state track changes without needing to redeploy infrastructure
The DeletionPolicy attribute can be changed to ‘Retain’ to keep existing resources instead of deleting them alongside a cloudformation stack.

Reference: [https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html)
