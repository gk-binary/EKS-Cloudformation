
# EKS Cloudformation template

    Creates VPC , subnets [ private and public ], route table, IAM roles and EKS cluster with nodegroups.
### Nodegroup Details
    1. Monitoring nodegroup - use this to deploy monitoring tools.
    2. Services nodegroup - use this to deploy applications.

### Subnet Details
    1. 3 Public Subnet
    2. 3 Private Subnet



    

## Variables
  Edit start.sh based on your requirement
```bash
    STACK_NAME="test-cluster-1"

    REGION="us-west-2"

    EKS_VERSION="1.26"

    VPC_CIDR="11.0.0.0/16"

    PUBLIC_SUBNET_CIDR="11.0.0.0/19,11.0.32.0/19,11.0.64.0/19"

    PRIVATE_SUBNET_CIDR="11.0.96.0/19,11.0.128.0/19,11.0.160.0/19"

    AWS_PROFILE="aws-test"

    AWS_ACCOUNT_ID="1234567890123"
```





## Prerequisite
    1. aws cli
    2. eksctl
    3. kubectl

## Installation
    1. clone the repo.
    2. run ./start.sh



## Authors

- [@gk-binary](https://github.com/gk-binary)

