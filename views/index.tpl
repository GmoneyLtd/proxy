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
            font-family: Arial, sans-serif;
            font-size: 12px;
            color: #333;
            height: 100vh;
            overflow: hidden;
        }

        h3 {
            margin-top: 10px;
            margin-bottom: 10px;
            font-size: 16px;
            font-family: 'Comic Sans MS', 'Trebuchet MS', 'Lucida Sans Unicode', 'Lucida Grande', 'Lucida Sans', Arial, sans-serif;
            font-weight: 800;
            text-align: center;
        }

        h4 {
            margin-top: 10px;
            margin-bottom: 10px;
            font-size: 12px;
            color: #e36433;
            font-style: italic;
            font-family: 'Comic Sans MS', 'Trebuchet MS', 'Lucida Sans Unicode', 'Lucida Grande', 'Lucida Sans', Arial, sans-serif;
            text-align: center;
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

        #info_table {
            border-collapse: collapse;
            margin: 0 auto;
            line-height: 20px;
            width: 90%;
            table-layout: fixed;
        }

        #info_table tr {
            height: 30px;
        }

        #info_table td {
            border: solid 1px #888;
            padding: 0px 10px;
            word-wrap: break-word;
            /* 设置自动换行 */
            white-space: pre-wrap;
            /* 设置自动换行 */
        }

        .info_table_label {
            width: 180px;
            font-style: italic;
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
            <table id="info_table" summary="display Info Table">
                % for key, value in headers.items():
                <tr>
                    <td class="info_table_label">{{key}}</td>
                    <td>{{value}}</td>
                </tr>
                % end
            </table>
        </div>
    </div>
    <div id="footer">&copy; 2024 Powered By Proxy PoC</div>
</body>

</html>