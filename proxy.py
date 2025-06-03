# proxy.py - Bottle-based simple proxy service (optimized and reconstructed version)

import logging
import os
from logging.handlers import TimedRotatingFileHandler

from bottle import Bottle, HTTPResponse, error, redirect, request, static_file, template
from waitress import serve

# ================== configuration settings ==================

APP_NAME = "Proxy PoC"
TEMPLATE_ROOT = os.path.join(os.path.dirname(__file__), "views")
STATIC_ROOT = os.path.join(os.path.dirname(__file__), "static")
LOG_DIR = os.path.join(os.path.dirname(__file__), "log")
os.makedirs(LOG_DIR, exist_ok=True)


SERVER_CONFIG = {
    "host": "0.0.0.0",
    "port": 8000,
    "channel_timeout": 60,
    "ident": f"[{APP_NAME}]",
    "threads": 4,
    # "trusted_proxy": "*",
    # "trusted_proxy_count": 5,
    # "trusted_proxy_headers": ["X-Forwarded-For", "X-Forwarded-Proto", "X-Forwarded-Host", "X-Forwarded-Port"],
    "clear_untrusted_proxy_headers": False,  # Set to False to not clear agent header information
}

# ================== initializing application ==================

app = Bottle(template_path=TEMPLATE_ROOT)

# ================== log configuration ==================


def setup_logger():
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")

    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)

    file_handler = TimedRotatingFileHandler(filename=os.path.join(LOG_DIR, "proxy.log"), when="midnight", interval=1, backupCount=7, encoding="utf-8")
    file_handler.suffix = "%Y-%m-%d.log"
    file_handler.setFormatter(formatter)

    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    root_logger.addHandler(console_handler)
    root_logger.addHandler(file_handler)

    # Waitress 日志
    waitress_logger = logging.getLogger("waitress")
    waitress_logger.propagate = False
    waitress_logger.setLevel(logging.INFO)
    waitress_logger.addHandler(console_handler)
    waitress_logger.addHandler(file_handler)

    # 应用日志
    app_logger = logging.getLogger("proxy")
    app_logger.propagate = False
    app_logger.setLevel(logging.INFO)
    if not app_logger.handlers:
        app_logger.addHandler(console_handler)
        app_logger.addHandler(file_handler)

    return app_logger


app_logger = setup_logger()

# ================== route definition ==================


@app.route("/static/<filepath:path>")
def serve_static(filepath):
    safe_path = os.path.normpath(os.path.join(STATIC_ROOT, filepath))
    if ".." in safe_path or not os.path.exists(safe_path):
        return HTTPResponse(status=403, body="Forbidden")
    resp = static_file(filepath, root=STATIC_ROOT)
    resp.set_header("Cache-Control", "public, max-age=86400")
    return resp


@app.route("/api/healthz", method="GET")
def health_check():
    return {"status": "ok", "message": "Service is running"}


@app.route("/", method="GET")
def root_redirect():
    redirect("/index")


@app.route("/error", method="GET")
def error_page():
    return template("error.tpl", error_msg="An unknown error occurred")


@app.route("/index", method="GET")
def index_page():
    source_info = f"[{request.environ.get('REMOTE_ADDR', 'unknown')}]:{request.environ.get('REMOTE_PORT', '')}"
    destination_info = f"[{request.headers.get('Host', 'unknown')}]"
    request_headers = dict(request.headers)
    app_logger.info({"source": source_info, "destination": destination_info, "request_headers": request_headers})

    return template("index.tpl", source_info=source_info, destination_info=destination_info, request_headers=request_headers)


@app.route("/debug", method="GET")
def debug_page():
    debug_info = request.query.info
    client_ip = request.environ.get("REMOTE_ADDR", "unknown")
    allowed_debug_types = {"environ", "request"}

    app_logger.debug(f"Debug request from {client_ip} with type: '{debug_info}'")

    if debug_info not in allowed_debug_types:
        return {"error": "Invalid debug info", "allowed_types": list(allowed_debug_types)}

    if debug_info == "environ":
        environ_copy = {key: str(value) for key, value in request.environ.copy().items()}
        return environ_copy

    elif debug_info == "request":
        return dict(request.headers)


# ================== Global error handling ==================


@app.route("/<path:path>")
def catch_all(path):
    accept_header = request.get_header("Accept", "")
    is_json = "application/json" in accept_header

    app_logger.warning(f"No matching route found: {request.method} {request.path}")

    if is_json:
        return HTTPResponse(status=404, body={"error": "Not Found", "message": f"path '/{path}' not exist"}, headers={"Content-Type": "application/json"})
    else:
        return template("error.tpl", error_msg=f"path '/{path}' not exist")


@error(500)
def handle_error_500(err):
    app_logger.exception(f"Internal Server Error: {err.body}")
    return template("error.tpl", error_msg="Internal Server Error")


# ================== start the service ==================

if __name__ == "__main__":
    app_logger.info(f"=============== {APP_NAME} service startup ===============")
    try:
        serve(app, **SERVER_CONFIG)
        # app.run(host=SERVER_CONFIG["host"], port=SERVER_CONFIG["port"], debug=True, reloader=True)
    except Exception as e:
        app_logger.critical(f"Server failed to start: {str(e)}", exc_info=True)
    finally:
        app_logger.info(f"=============== {APP_NAME} service is stopped ===============")
