"""
Lambda function to create n number of
EC2 instances based on .pub keys in an S3 bucket
"""

import boto3
import os

EC2 = boto3.resource('ec2')
S3 = boto3.resource('s3')
EBS = boto3.resource('ebs')

BUCKET_ID = os.environ('bucket_id')

def get_s3_keys(BUCKET_ID):
    """
    Function to get .pub keys in an s3 bucket
    """
    bucket = S3.Bucket(BUCKET_ID)
    
    keys = []
    
    for obj in bucket.objects.all():
        keys.append(obj.key)
        
    return keys    
    

def create_ebs_volumes(keys):
    """
    Function to create an EBS volume for every .pub file
    """
    x = 'temp'
    return x

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
