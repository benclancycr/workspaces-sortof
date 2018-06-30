"""
Lambda function to create n number of
EC2 instances based on .pub keys in an S3 bucket
"""

import boto3
import os

EC2 = boto3.resource('ec2')
S3 = boto3.resource('s3')
EBS = boto3.resource('ebs')

bucket_id = os.environ('bucket_id')

def get_s3_files(bucket_id):
    """
    Function to get a list of all .pub files in a bucket
    """

def lambda_handler(event,context):
    """
    Lambda function
    """
    print(event)
    print(context)
