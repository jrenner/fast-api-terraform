import boto3
from logzero import logger
from rich import print


def read_from_s3(bucket, key):
    logger.info(f"read from s3: {bucket}, {key}")
    s3 = boto3.resource("s3")
    obj = s3.Object(bucket, key).get()
    body = obj["Body"]
    output = str(body.read(), encoding="utf-8")
    return output


if __name__ == "__main__":
    res = read_from_s3("jrenner-learn-bucket", "test_data.txt")
    print(type(res))
    print(res)
