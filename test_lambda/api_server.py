from fastapi import FastAPI
from mangum import Mangum
from logzero import logger

app = FastAPI()


@app.get("/main")
def api_main():
    logger.info("api_main")
    return {"message": "Hello World api/main"}


@app.get("/")
def root():
    logger.info("root")
    return {"message": "hello world /"}


@app.get("/api")
def root_api():
    logger.info("root_api")
    return {"message": "hello world api root"}


@app.get("/one")
def one():
    logger.info("one")
    return {"one": 1}


@app.get("/two")
def two():
    logger.info("two")
    return {"two": 2}


@app.get("/items/{name}")
def read_item(name: str):
    res = {"message": f"search for item: {name}", "result": "not found"}
    logger.info(res)
    logger.info(f"res: {res}")
    return res


def raw_handler(event, context):
    print("start print")
    print(f"print event: {event}")
    logger.info(event)
    logger.info(f"event: {event}")
    logger.info(f"context: {context}")
    asgi_handler = Mangum(app, api_gateway_base_path="/api")
    response = asgi_handler(event, context)
    return response


handler = raw_handler
