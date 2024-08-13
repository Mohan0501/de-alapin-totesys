from pg8000.native import Connection, Error
from botocore.exceptions import ClientError
import boto3
import json

def get_database_credentials():
    secret_name = "totesys-database"
    #region_name = "eu-west-2"

    client = boto3.client('secretsmanager')

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        raise e

    secret = get_secret_value_response['SecretString']
    secret_dict = json.loads(secret)
    return secret_dict


# Your code goes here.

def connect_to_db():
    return Connection(
        ***REMOVED***
        ***REMOVED***
        ***REMOVED***
        ***REMOVED***,
        port=5432
    )

def full_fetch():
    pass

