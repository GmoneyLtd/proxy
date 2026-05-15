<!DOCTYPE html>
<html lang="en">

<head>
    <title>Proxy PoC</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/svg+xml" href="/static/proxy.svg">
    <!-- <link href="https://fonts.googleapis.com/css?family=Open+Sans&display=swap" rel="stylesheet"> -->
    <style>
        body {
            margin: 0;
            padding: 0;
            font-style: normal;
            font-weight: normal;
            font-family: Cambria, Cochin, Georgia, Times, 'Times New Roman', serif;
            letter-spacing: 0.5px;
            font-size: 12px;
            color: #333;
            height: 100vh;
            overflow: hidden;
        }

        .button-container {
            text-align: center;
            margin: 10px 0;
        }

        .button-container button {
            padding: 8px 15px;
            background-color: #c2c9d0;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            font-family: Cambria, Cochin, Georgia, Times, 'Times New Roman', serif;
        }

        .button-container button:hover {
            background-color: #d34959;
        }

        #response_headers_table {
            display: none;
            /* Initially hidden */
        }

        h3 {
            margin-top: 10px;
            margin-bottom: 10px;
            font-size: 16px;
            color: rgb(18, 86, 143);
            /* font-family: 'Comic Sans MS', 'Trebuchet MS', 'Lucida Sans Unicode', 'Lucida Grande', 'Lucida Sans', Arial, sans-serif; */
            font-weight: 600;
            text-align: center;
        }

        h4 {
            margin-top: 10px;
            margin-bottom: 10px;
            font-size: 12px;
            font-weight: 400;
            color: rgb(40, 133, 133);
            font-style: italic;
            /* font-family: 'Comic Sans MS', 'Trebuchet MS', 'Lucida Sans Unicode', 'Lucida Grande', 'Lucida Sans', Arial, sans-serif; */
            text-align: center;
        }

        p {
            /* padding: 10px 0px 10px 40px; */
            margin: 10px 0;
            font-size: 16px;
            /* font-family: 'Comic Sans MS', 'Trebuchet MS', 'Lucida Sans Unicode', 'Lucida Grande', 'Lucida Sans', Arial, sans-serif; */
            font-weight: 500;
            position: relative;
            display: inline-block;
            /* left: 20px; */
            margin-left: 20px;
            text-decoration: underline;
            /* 为文本添加下划线 */
            text-decoration-color: #e36433;
            /* 下划线颜色 */
            text-decoration-thickness: 1px;
            /* 下划线厚度 */
            text-underline-offset: 8px;
            /* 下划线偏移量 */
            text-decoration-skip-ink: none;
            /* 跳过下划线和文本的墨水 */
        }

        #container {
            background: white;
            width: 90%;
            margin: 10px auto;
            margin-bottom: 10px;
            border: solid 1px #bbb;
            overflow-y: scroll;
            height: 90vh;
            -ms-overflow-style: none;
            /* IE 和 Edge 隐藏滚动条 */
            scrollbar-width: none;
            /* Firefox 隐藏滚动条 */
        }

        /* Chrome 和 Safari 隐藏滚动条 */
        #container ::-webkit-scrollbar {
            display: none;
        }

        #info_area {
            margin: 10px auto;
        }

        .info_table {
            border-collapse: collapse;
            margin: 0 auto;
            line-height: 20px;
            width: 90%;
            table-layout: fixed;
        }

        .info_table tr {
            height: 30px;
        }

        .info_table td {
            border: solid 1px #888;
            padding: 0px 10px;
            word-wrap: break-word;
            /* 设置自动换行 */
            white-space: pre-wrap;
            /* 设置自动换行 */
        }

        .info_table_label {
            width: 180px;
            /* font-style: italic; */
            font-weight: 580;
        }

        #footer {
            text-align: center;
            padding-bottom: 10px;
            background-color: transparent;
            /* 背景色透明 */
            position: fixed;
            bottom: 0;
            width: 100%;
        }
    </style>
</head>

<body>
    <div id="container">
        <div id="info_area">
            <h3>display source IP and HTTP headers</h3>
            <h4>Source IP => {{source_info}}</h4>
            <div class="button-container">
                <button id="toggle_response_headers_btn">Show / Hide HTTP Headers</button>
            </div>
            <p>The following is the client request header information</p>
            <table class="info_table" summary="Client request Headers">
                % for key, value in request_headers.items():
                <tr>
                    <td class="info_table_label">{{key}}</td>
                    <td>{{value}}</td>
                </tr>
                % end
            </table>
            <p id="response_headers_info">The following is the server response header information</p>
            <table class="info_table" id="response_headers_table" summary="Server Response Headers">
                <!-- Response headers will be populated here by JavaScript -->
            </table>
            <div style="height: 50px;"></div>
        </div>
    </div>
    <div id="footer">&copy; 2026 Powered By Proxy PoC</div>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const toggleButton = document.getElementById('toggle_response_headers_btn');
            const responseHeadersTable = document.getElementById('response_headers_table');
            const responseHeadersInfo = document.getElementById('response_headers_info');
            const responseHeadersTbody = responseHeadersTable.createTBody(); // Create tbody element

            function fetchAndDisplayResponseHeaders() {
                fetch(window.location.href, {
                    method: 'GET',
                    redirect: 'manual',
                    headers: { 'X-Requested-With': 'XMLHttpRequest' }
                })
                    .then(response => {
                        const headers = {};
                        response.headers.forEach((value, key) => {
                            headers[key] = value;
                        });

                        responseHeadersTbody.innerHTML = '';
                        let hasHeaders = false;
                        for (const key in headers) {
                            if (headers.hasOwnProperty(key)) {
                                const row = responseHeadersTbody.insertRow();
                                const keyCell = row.insertCell();
                                const valueCell = row.insertCell();
                                keyCell.className = 'info_table_label';
                                keyCell.textContent = key;
                                valueCell.textContent = headers[key];
                                hasHeaders = true;
                            }
                        }

                        if (!hasHeaders) {
                            const row = responseHeadersTbody.insertRow();
                            const cell = row.insertCell();
                            cell.colSpan = 2;
                            cell.textContent = '没有获取到响应头信息。';
                            cell.style.textAlign = 'center';
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching headers:', error);
                        responseHeadersTbody.innerHTML = '';
                        const row = responseHeadersTbody.insertRow();
                        const cell = row.insertCell();
                        cell.colSpan = 2;
                        cell.textContent = '获取响应头时发生错误。';
                        cell.style.textAlign = 'center';
                    });
            }

            function displayResponseHeaders() {
                fetchAndDisplayResponseHeaders();
            }

            // 初始设置为隐藏
            responseHeadersTable.style.display = 'none';
            responseHeadersInfo.style.display = 'none';

            // 添加点击事件监听器
            toggleButton.addEventListener('click', function () {
                if (responseHeadersTable.style.display === 'none') {
                    responseHeadersTable.style.display = 'table';
                    responseHeadersInfo.style.display = 'block';
                    displayResponseHeaders(); // 显示并加载数据
                } else {
                    responseHeadersTable.style.display = 'none';
                    responseHeadersInfo.style.display = 'none';
                }
            });
        });
    </script>
</body>

</html>