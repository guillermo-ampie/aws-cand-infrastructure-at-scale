import os

def lambda_handler(event, context):
    output = "{}, greetings from Lambda!".format(os.environ['greeting'])
    print(output)
    return output
