# This is a simple proxy server that can be used to intercept and modify HTTP requests and responses.
import logging
from bottle import Bottle, redirect, request, run, template, static_file, url
import os


app = Bottle()

# 配置日志记录
logging.basicConfig(filename="./log/proxy.log", filemode="a", level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")


# 确保静态文件目录不会包含如.env或.py等敏感文件，以防止未经授权的访问, 在文件存储时严格控制路径并开启文件本地缓存
@app.route('/static/<filepath:path>')
def serve_static(filepath):
    safe_path = os.path.join('./static', filepath)
    if not os.path.exists(safe_path):
        return "File not found", 404
    response = static_file(filepath, root='./static')
    response.set_header('Cache-Control', 'public, max-age=86400')  # 启用缓存，缓存一天
    return response


@app.route("/api/health-check", method="GET")
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
        headers_msg += f"{k} -> [{v}] -/- "

    # 记录日志
    logging.info(f"source_info => {source_info} || destination_info => {destination_info} || headers => [{headers_msg}]")

    # 渲染模板并传递源IP和头信息
    return template("index", source_info=source_info, destination_info=destination_info, headers=headers)


if __name__ == "__main__":
    from gevent import monkey

    monkey.patch_all()

    run(app, host="::", port=8000, server="gevent", debug=True, reloader=True)
