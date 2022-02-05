import json
from re import I



class LambdaProxyResponse:
    def __init__(self, body: dict):
        self.body = body

    def build(self):
        http_status_code = 200
        headers = {}
        data = {
            "isBase64Encoded": False,
            "statusCode": http_status_code,
            "headers": headers,
            "body": self.body,
        }
        return data

    def to_json(self):
        return json.dumps(self.build())




def handler(event, context):
    print(f"event: {event}")
    print(f"context: {context}")
    res = {
            "message": "ok",
            "number": 1234,
            }
    resp = LambdaProxyResponse(body=res)
    return resp.to_json()

if __name__ == "__main__":
    ev = {"key1": 1}
    ctx = "contextDummy"
    res = handler(ev, ctx)
    print(res)
