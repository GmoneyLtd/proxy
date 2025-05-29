# This is a simple proxy server that can be used to intercept and modify HTTP requests and responses.
import logging
import os
from logging.handlers import TimedRotatingFileHandler

from bottle import Bottle, redirect, request, response, static_file, template
from waitress import serve

app = Bottle()


# 确保静态文件目录不会包含如.env或.py等敏感文件，以防止未经授权的访问, 在文件存储时严格控制路径并开启文件本地缓存
@app.route("/static/<filepath:path>")
def serve_static(filepath):
    safe_path = os.path.join("./static", filepath)
    if not os.path.exists(safe_path):
        return "File not found", 404
    response = static_file(filepath, root="./static")
    response.set_header("Cache-Control", "public, max-age=86400")  # 启用缓存，缓存一天
    return response


@app.route("/api/healthz", method="GET")
def health_check():
    # 返回健康状态信息
    return {"status": "ok", "message": "Service is running"}


@app.route("/", method="GET")
def proxy():
    redirect("/index")


@app.route("/index", method="GET")
def index_page():
    # 获取请求的源IP地址
    source_info = f"[{request.get('REMOTE_ADDR')}]:{request.get('REMOTE_PORT')}"
    # 获取请求的目的IP地址
    destination_info = f"[{request.get('HTTP_HOST')}]"

    # 获取请求的HTTP头信息
    headers = dict(request.headers)
    headers_msg = ""
    for k, v in headers.items():
        headers_msg += f"{k} --> {v} |#| "

    # 记录日志
    app_logger.info(f"source_info -> {source_info} |=| destination_info -> {destination_info} |=| headers -> [{headers_msg}]")

    # 渲染模板
    return template("index", source_info=source_info, destination_info=destination_info, headers=headers)


if __name__ == "__main__":
    # 创建格式化器
    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")

    # 控制台日志处理器
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)

    # 文件日志处理器
    file_handler = TimedRotatingFileHandler(filename=os.path.join("./log", "proxy.log"), when="midnight", interval=1, backupCount=7, encoding="utf-8", utc=False, delay=False)
    file_handler.suffix = "%Y-%m-%d.log"  # 设置文件名后缀为日期格式
    file_handler.setFormatter(formatter)

    # 配置根日志器
    root_logger = logging.getLogger()
    # 清除可能存在的处理器
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)

    root_logger.setLevel(logging.INFO)
    root_logger.addHandler(console_handler)
    root_logger.addHandler(file_handler)

    # 配置 Waitress 日志器, waitress package 本身定义的也是该日志器
    waitress_logger = logging.getLogger("waitress")
    waitress_logger.propagate = False  # 防止日志向上传递到根日志器
    waitress_logger.setLevel(logging.INFO)
    waitress_logger.addHandler(console_handler)
    waitress_logger.addHandler(file_handler)

    # 配置应用日志器
    app_logger = logging.getLogger("proxy")
    app_logger.propagate = False  # 防止日志向上传递到根日志器
    app_logger.setLevel(logging.INFO)
    app_logger.addHandler(console_handler)
    app_logger.addHandler(file_handler)

    # 记录应用启动信息
    app_logger.info("=============== Proxy PoC 服务启动 ===============")
    # 启动服务器
    trusted_proxy_headers = ["X-Forwarded-For", "X-Forwarded-Proto", "X-Forwarded-Host", "X-Forwarded-Port"]
    serve(app, host="0.0.0.0", port=8000, channel_timeout=60, ident="[Proxy PoC]", threads=4, trusted_proxy="*", trusted_proxy_count=5, trusted_proxy_headers=trusted_proxy_headers)
