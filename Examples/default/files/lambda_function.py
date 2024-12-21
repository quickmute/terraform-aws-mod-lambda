def lambda_handler(event, context):
    print("helllo world")
    print(event)
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'text/html; charset=utf-8'
        },
        'body': '<p>Hello world!</p>'
    }
