"""
Lambda function to stop all ec2 instances in a vpc
"""

import boto3

EC2 = boto3.resource('ec2')

def get_instances():
    """
    Function to get all instances 
    """
    filters = [
        {
            'Name': 'instance-state-name',
            'Values': ['*']
        }
    ]
    
    instances = EC2.instances.filter(Filters=filters)
    
    Instances = []
    
    for instance in instances:
        Instances.append(instance.id)
    
    return Instances

def stop_instances(ec2_instances):
    """
    Function to stop all instances passed
    """
    for ec2_instance in ec2_instances:
        EC2.instances.stop(ec2_instance)
    

def lambda_handler(event,context):
    """
    Lambda function
    """
    print(event)
    print(context)
    instances = get_instances()
    stop_instances(instances)