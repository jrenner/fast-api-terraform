import json
from re import I


class LambdaProxyResponse:
    def __init__(self, body: dict):
        self.body = body

    def build(self):
        http_status_code = 200
        headers = {}
        data = {
            # "isBase64Encoded": False,
            "statusCode": http_status_code,
            # "headers": headers,
            "body": json.dumps(self.body),
        }
        return data


def handler(event, context):
    print(f"event: {event}")
    print(f"context: {context}")
    data = {
        "message": "ok",
        "number": 1234,
    }
    res = LambdaProxyResponse(body=data).build()
    print(f"returning result: {res}")
    print(f"result type: {type(res)}")
    return res


if __name__ == "__main__":
    ev = {"key1": 1}
    ctx = "contextDummy"
    res = handler(ev, ctx)
    print(res)
