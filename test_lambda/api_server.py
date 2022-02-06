import decimal
import enum
import os
from typing import Optional

import uuid
from fastapi import FastAPI, Request
from fastapi.openapi.docs import get_swagger_ui_html
from mangum import Mangum
from logzero import logger
from rich.pretty import pretty_repr

from datetime import date, datetime
from dateutil.parser import parse as parse_date
from pydantic import BaseModel


class ApiServerException(Exception):
    pass


try:
    STAGE = os.environ["STAGE"]
except KeyError:
    raise ApiServerException(f"STAGE env var not set")


def create_fast_api_app():
    if STAGE == "local":
        root_path = ""
    elif STAGE in ["dev", "prod"]:
        root_path = f"/{STAGE}/api"
    else:
        raise ApiServerException(f"invalid stage: {STAGE}")
    logger.info(f"create fast api app with root path: {root_path}")
    return FastAPI(root_path=root_path)


def create_mangum_handler(app):
    if STAGE == "local":
        base_path = ""
    else:
        base_path = "/api"
    logger.info(f"create Mangum with base path: {base_path}")
    return Mangum(app, api_gateway_base_path=base_path)


app = create_fast_api_app()


@app.get("/main")
def api_main(request: Request):
    logger.info(pretty_repr(request.scope))
    root_path = request.scope.get("root_path")
    logger.info("api_main")
    return {
        "message": "Hello World api/main",
        "root_path": root_path,
        "scope": {k: pretty_repr(v) for k, v in request.scope.items()},
    }


@app.get("/")
def root(request: Request):
    logger.info(pretty_repr(request.scope))
    logger.info("root")
    root_path = request.scope.get("root_path")
    return {"message": "hello world /", "root_path": root_path}


@app.get("/api")
def root_api(request: Request):
    logger.info(pretty_repr(request.scope))
    logger.info("root_api")
    return {"message": "hello world api root"}


@app.get("/one")
def one(request: Request):
    logger.info(pretty_repr(request.scope))
    logger.info("one")
    return {"one": 1}


@app.get("/two")
def two(request: Request):
    logger.info(pretty_repr(request.scope))
    logger.info("two")
    return {"two": 2}


@app.get("/items/{name}")
def read_item(name: str, request: Request):
    logger.info(pretty_repr(request.scope))
    res = {"message": f"search for item: {name}", "result": "not found"}
    logger.info(res)
    logger.info(f"res: {res}")
    return res


class IntensityLevel(enum.Enum):
    Low = "low"
    Medium = "medium"
    High = "high"


class DataObject(BaseModel):
    id: int
    name: str
    ratio: decimal.Decimal
    joined: date
    left: Optional[date]
    intensity: IntensityLevel


data_objs = {
    0: DataObject(
        id=0,
        name="zero",
        ratio=0.34,
        joined=parse_date("2020/06/01").date(),
        intensity=IntensityLevel.Medium,
    ),
    1: DataObject(
        id=1,
        name="one",
        ratio=1.2,
        joined=parse_date("2021/03/15").date(),
        intensity=IntensityLevel.High,
    ),
}


@app.get("/data/{id}")
def get_data(id: int) -> Optional[DataObject]:
    res = data_objs.get(id, None)
    logger.info(f"get_data for id: {id}: {res}")
    return res


@app.put("/data")
def put_data(dobj: DataObject) -> int:
    logger.info(f"put data obj: {dobj}")
    data_objs[dobj.id] = dobj
    return dobj.id


def raw_handler(event, context):
    if STAGE == "local":
        base_path = ""
    elif STAGE in ["dev", "prod"]:
        base_path = "/api"
    else:
        raise ApiServerException(f"invalid stage: {STAGE}")
    logger.info(f'base_path: "{base_path}"')
    logger.info(f"context: {context}")
    logger.info(f"event: {event}")
    asgi_handler = Mangum(app, api_gateway_base_path=base_path)
    response = asgi_handler(event, context)
    return response


handler = raw_handler
