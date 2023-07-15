#!/bin/bash

set -e

#  edit this part of file
#------------------------------------------------------------------------------#

STACK_NAME="test-cluster-1"
REGION="us-west-2"
EKS_VERSION="1.26"
VPC_CIDR="11.0.0.0/16"
PUBLIC_SUBNET_CIDR="11.0.0.0/19,11.0.32.0/19,11.0.64.0/19"
PRIVATE_SUBNET_CIDR="11.0.96.0/19,11.0.128.0/19,11.0.160.0/19"
AWS_PROFILE="aws-test" # aws cli profile
AWS_ACCOUNT_ID="1234567890123"

#------------------------------------------------------------------------------#


# Output colours
COL='\033[1;34m'
NOC='\033[0m'



echo -e "$COL> Deploying CloudFormation stack (may take up to 15 minutes)...$NOC"
aws cloudformation deploy \
  --region "$REGION" \
  --template-file infrasetup.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --stack-name "$STACK_NAME" \
  --parameter-overrides \
      ClusterName="$STACK_NAME" \
      EksVersion="$EKS_VERSION" \
      VpcCIDR="$VPC_CIDR" \
      PublicSubnetCIDR="$PUBLIC_SUBNET_CIDR" \
      PrivateSubnetCIDR="$PRIVATE_SUBNET_CIDR" \
  --profile "$AWS_PROFILE" \
  --color on 

echo -e "\n$COL> Updating kubeconfig file...$NOC"

aws eks update-kubeconfig \
  --name "$STACK_NAME" \
  --region "$REGION" \
  --profile "$AWS_PROFILE" 

echo -e "\n$COL> Configuring worker nodes (to join the cluster)...$NOC"
# Get worker nodes role ARN from CloudFormation stack output
arn=$(aws cloudformation describe-stacks \
  --region "$REGION" \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='EKSNodeRoleArn'].OutputValue" \
  --output text \
  --profile "$AWS_PROFILE" )

# Enable worker nodes to join the cluster

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: $arn
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::$AWS_ACCOUNT_ID:root
      groups:
        - system:masters
EOF

echo -e "\n$COL> Almost done! The cluster will be ready when all nodes have a 'Ready' status."
echo -e "> Checking nodes listing: kubectl get nodes --watch$NOC"

kubectl get nodes 