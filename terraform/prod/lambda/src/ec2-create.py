"""
Lambda function to create n number of
EC2 instances based on .pub keys in an S3 bucket
"""

import boto3
import os
import json

EC2 = boto3.resource('ec2')

def modify_key(self):
    """
    Function to get key name
    """
    keyname_with_extension = self['Records'][0]['s3']['object']['key']
    keyname = os.path.split(keyname_with_extension)[0]
    return keyname

def create_ec2_instances(self):
    """
    Function to create EC2 instances for every .pub file
    """
    
    instance = EC2.create_instances(
        ImageId="ami-466768ac",
        MinCount=1,
        MaxCount=1,
        InstanceType="t2.micro",
        BlockDeviceMappings=[
            {
                'DeviceName': '/dev/sda1',
                'Ebs': {
                    'VolumeSize': 32,
                    'DeleteOnTermination': True,
                    'VolumeType': 'standard',
                    },
            },
        ]
        )
    EC2.create_tags(Resources=[instance[0].instance_id], Tags=[{'Key':'name', 'Value':self}])

def lambda_handler(event,context):
    """
    Lambda function
    """
    hostname = modify_key(event)
    create_ec2_instances(hostname)