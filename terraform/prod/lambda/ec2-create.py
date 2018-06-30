"""
Lambda function to create n number of
EC2 instances based on .pub keys in an S3 bucket
"""

import boto3

EC2 = boto3.resource('ec2')

    

def lambda_handler(event,context):
    """
    Lambda function
    """
    print(event)
    print(context)
