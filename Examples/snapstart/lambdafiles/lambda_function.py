import boto3
import pandas
import openpyxl
import time
import logging
import os
import json

## Initialization Code here
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def reverse_print(s):
    reversed_str = ""
    for char in s:
        reversed_str = char + reversed_str
        print(reversed_str)

def lambda_handler(event, context):
    for item in event['Records']:
        for key, value in item.items():
            print(key, value)
            if key == 'Sns':
                for k, v in value.items():
                    print(k, v)
                    if k == 'Message':
                        reverse_print(v)
    
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'text/html; charset=utf-8'
        },
        'body': '<p>Hello world2!</p>'
    }

