# import logging
# from rich.logging import RichHandler
#
#
# def create_logger():
#     root = logging.getLogger()
#     if root.handlers:
#         for handler in root.handlers:
#             root.removeHandler(handler)
#     #format = "[%(asctime)s] %(message)s"
#     format = "%(message)s"
#     #date_format = "%Y-%m-%d %H:%M:%S"
#     date_format = "%X"
#     log_level = logging.DEBUG
#     rich_handler = RichHandler(show_time=True)
#     logging.basicConfig(
#         level=log_level, format=format, datefmt=date_format, handlers=[rich_handler]
#     )
#     logger = logging.getLogger("test_lambda_logger")
#     logger.info("created logger")
#
#     logger.debug("debug check")
#     logger.info("info check")
#     logger.warning("warning check")
#     logger.error("error check")
#     return logger
#
#
# logger = create_logger()
