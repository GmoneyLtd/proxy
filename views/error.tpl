<!DOCTYPE html>
<html lang="en">

<head>
    <title>Proxy ERROR</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" type="image/svg+xml" href="/static/proxy.svg">
    <!-- <link href="https://fonts.googleapis.com/css?family=Open+Sans&display=swap" rel="stylesheet"> -->
    <style>
        * {
            font-family: Cambria, Cochin, Georgia, Times, 'Times New Roman', serif;
            letter-spacing: 0.5px;
            
        }
        main {
            
            padding: 40px 20px;
        }

        .upload-container {
            max-width: 600px;
            margin: 0 auto;
            margin-top: 40px;
            /* 新增的上边距 */
        }

        .upload-box {
            background-color: #fff;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 10px;
        }

        h2 {
            font-size: 20px;
            font-weight: 500;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            /* justify-content: center; */
            gap: 10px;
        }
    </style>
</head>

<body>
    <main>
        <div class="upload-container">
            <div class="upload-box">
                <h2>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20">
                        <path d="M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm1 17h-2v-2h2v2zm0-4h-2v-6h2v6z" />
                    </svg>
                    <span>warnning</span>
                </h2>
                <p>{{error_msg}}</p>
            </div>
        </div>
    </main>
</body>

</html>