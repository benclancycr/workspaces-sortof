"""
Lambda function to create n number of
EC2 instances based on .pub keys in an S3 bucket
"""

import boto3
import os

EC2 = boto3.resource('ec2')
EBS = boto3.resource('ebs')

def create_ebs_volumes(self):
    """
    Function to create an EBS volume for every .pub file
    """
    EC2.create_ebs_volumes(volume_name)

def create_ec2_instances(keys, volumes):
    """
    Function to create EC2 instances for every .pub file
    """

def lambda_handler(event,context):
    """
    Lambda function
    """
    print(event)
    print(context)
    keys = get_s3_keys(BUCKET_ID)
    volumes = create_ebs_volumes(keys)
    create_ec2_instances(keys, volumes)
