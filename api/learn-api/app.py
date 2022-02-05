from chalice import Chalice
from datetime import datetime
import chalicelib.read_data as read_data
from logzero import logger
from rich import print

app = Chalice(app_name="learn-api")


@app.route("/")
def index():
    return {"hello": "world"}


@app.route("/other")
def other():
    return {"message": f"this is other date {datetime.now().isoformat()}"}


@app.route("/read_data/{key}")
def read_data_call(key: str):
    bucket = "jrenner-learn-bucket"
    logger.info("read_data call - key: {key}")
    res = read_data.read_from_s3(bucket, key)
    return res


# The view function above will return {"hello": "world"}
# whenever you make an HTTP GET request to '/'.
#
# Here are a few more examples:
#
# @app.route('/hello/{name}')
# def hello_name(name):
#    # '/hello/james' -> {"hello": "james"}
#    return {'hello': name}
#
# @app.route('/users', methods=['POST'])
# def create_user():
#     # This is the JSON body the user sent in their POST request.
#     user_as_json = app.current_request.json_body
#     # We'll echo the json body back to the user in a 'user' key.
#     return {'user': user_as_json}
#
# See the README documentation for more examples.
#
