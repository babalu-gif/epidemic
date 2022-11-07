<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String base = request.getContextPath() + "/";
String url = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + base;
%>

<head>
    <base href="<%=url%>">
    <title>login</title>
    <link rel="stylesheet" href="css/bootstrap.css" />
    <link rel="stylesheet" href="css/login.css" />
    <script type="text/javascript" src="jquery/jquery-2.1.1.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap.js"></script>
    <script type="text/javascript" src="jquery/layer-3.5.1/layer.js"></script>
    <style>
        body {
            position: relative;
        }

        .bg {
            position: absolute;
            width: 100%;
        }

        .login {
            position: absolute;
            top: 225px;
            left: 320px;
            width: 400px;
            height: 400px;
            border: 1px solid #d5d5d5;
            text-align: center;
        }

        #verify {
            height: 34px;
            vertical-align: top;
            font-size: 16px;
        }

        #code_img {
            width: 100px;
            height: 40px;
            cursor: pointer;
            vertical-align: top;
        }
    </style>
</head>

<script type="text/javascript">
    window.onload = function () {
        // 显示与隐藏密码
        var eye = document.getElementById('eye')
        var password = document.getElementById('password')
        var flag = 0
        eye.onclick = function () {
            if (flag === 0) {
                eye.src = './images/open.png'
                password.type = 'text'
                flag = 1
                // console.log('开了');
            } else {
                eye.src = './images/close.png'
                password.type = 'password'
                flag = 0
            }
        }
    }
    var rand = new Array();
    $(function (){
        if ("admin" == "${cookie.select.value}"){
            $("[selected]").attr("selected", false);
            $("#admin").attr("selected", "selected");
        } else if ("teacher" == "${cookie.select.value}"){
            $("[selected]").attr("selected", false);
            $("#teacher").attr("selected", "selected");
        } else if ("student" == "${cookie.select.value}"){
            $("[selected]").attr("selected", false);
            $("#student").attr("selected", "selected");
        }

        // 给登录按钮添加单击事件
        $("#loginBtn").click(function (){
            var userName = $.trim($("#userName").val());
            var password = $.trim($("#password").val());
            var isRemPwd = $("#isRemPwd").prop("checked");
            var identity = $("#identity").val();
            var verify = $.trim($("#verify").val());
            var verifyCanvas = rand[0]+rand[1]+rand[2]+rand[3];
            // 表单验证
            if (userName == ""){
                layer.alert("用户名不能为空", {icon: 7});
                return;
            }
            if (password == ""){
                layer.alert("密码不能为空", {icon: 7});
                return;
            }
            if (verify == ""){
                layer.alert("验证码不能为空", {icon: 7});
                return;
            }
            if (verify.toLowerCase() != verifyCanvas.toLowerCase() && verify.toUpperCase() != verifyCanvas.toUpperCase()){
                layer.alert("验证码错误", {icon: 7});
                drawCode();
                $("#verify").val("");
                return;
            }

            $("#msg").text("正在努力验证...");

            $.ajax({
                url: "admin/login.do",
                data: {
                    userName:userName,
                    password:password,
                    isRemPwd:isRemPwd,
                    identity:identity
                },
                type:"post",
                dataType:"json",
                success:function (data){
                if (data.code == "1"){
                    if (identity == "admin"){
                        // 跳转到主页面
                        window.location.href="admin/toMain.do";
                    } else if (identity == "teacher"){
                        // 跳转到主页面
                        window.location.href="teacher/toMain.do";
                    } else if (identity == "student"){
                        // 跳转到主页面
                        window.location.href="student/toMain.do";
                    }
                } else {
                    layer.alert(data.message, {icon:5});
                    drawCode();
                    $("#msg").text("");
                    $("#verify").val("");
                }
            }
            });
        });

        // 给整个浏览器窗口添加键盘按下事件
        $(window).keydown(function (event){
            // 如果按的是回车键
            if (event.keyCode == 13){
                $("#loginBtn").click();
            }
        });

        var is = $("#isRemPwd").prop("checked");
        if (is){
            autoLogin();
        }

    })

    function autoLogin() {//注意：此处不能使用jQuery中的change事件，因为仅触发一次，因此使用标签的：onchange属性
        var userName = $.trim($("#userName").val());
        var password = $.trim($("#password").val());
        var isRemPwd = $("#isRemPwd").prop("checked");
        var identity = $("#identity").val();
        // 表单验证
        if (userName == ""){
            layer.alert("用户名不能为空", {icon: 7});
            return;
        }
        if (password == ""){
            layer.alert("密码不能为空", {icon: 7});
            return;
        }

        $("#msg").text("正在努力验证...");

        $.ajax({
            url: "admin/login.do",
            data: {
                userName:userName,
                password:password,
                isRemPwd:isRemPwd,
                identity:identity
            },
            type:"post",
            dataType:"json",
            success:function (data){
                if (data.code == "1"){
                    if (identity == "admin"){
                        // 跳转到主页面
                        window.location.href="admin/toMain.do";
                    } else if (identity == "teacher"){
                        // 跳转到主页面
                        window.location.href="teacher/toMain.do";
                    } else if (identity == "student"){
                        // 跳转到主页面
                        window.location.href="student/toMain.do";
                    }
                } else {
                    layer.alert(data.message, {icon:5});
                    drawCode();
                    $("#msg").text("");
                }
            }
        });
    }
</script>

<body>
    <img src="images/bg.jpg" alt="" class="bg">
    <div class="login">
        <h3>登录</h3>

        <form action="" class="form-horizontal" role="form">
            <div class="form-group form-group-lg">
                <div style="width: 300px;position: absolute;left: 25px;">
                    <input class="form-control" id="userName" type="text" value="${cookie.adminName.value}" placeholder="用户名">
                </div>
                <div style="width: 300px;position: absolute;top: 120px; left: 25px;">
                    <%--<label for=""></label>--%>
                    <img src="./images/close.png" id="eye" style="position: absolute; top: 18px;right: 20px; width: 24px">
                    <input class="form-control" id="password" type="password" value="${cookie.password1.value}" placeholder="密码">
                </div>
                <div class="checkbox" style="position: absolute;top: 160px; left: 25px;">

                    <span id="msg"></span>
                    <p style="position: absolute;top: 30px;height: 40px">
                        <input type="text" class="topAlign" id="verify" name="verify" required
                            style="width: 130px;height: 100%;">
                        <canvas width="130px" height="40px" id="verifyCanvas"
                            style="position:absolute; top: 0px;left: 140px;"></canvas>
                        <img id="code_img" style="position: absolute;top: -2px;left: 170px;width: 130px">
                    </p>
                </div>

                <div style="width: 300px;position: absolute;top: 230px; left: 25px;margin-top: 10px">
                    <select id="identity" class="form-control">
                        <option id="admin" value="admin" selected>管理员</option>
                        <option id="teacher" value="teacher">教师</option>
                        <option id="student" value="student">学生</option>
                    </select>
                </div>
                <label style="position: absolute;top: 300px;left: 30px;height: 100%;font-size: 16px">
                    <c:if test="${not empty cookie.adminName and not empty cookie.password1}">
                        <input id="isRemPwd" type="checkbox" checked> 十天内免登录
                    </c:if>
                    <c:if test="${empty cookie.adminName or empty cookie.password1}">
                        <input id="isRemPwd" type="checkbox"> 十天内免登录
                    </c:if>
                    &nbsp;&nbsp;</label>
                <input value="登录" type="button" id="loginBtn" class="btn btn-primary btn-lg btn-block"
                       style="width: 300px; position: absolute;top: 340px;left: 25px;"></input>

            </div>
        </form>
    </div>
</body>
<script>
    var nums = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
        'L', 'M', 'N', 'O', 'P', 'Q', 'R',
        'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
        'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
        'y', 'z'
    ];
    var colors = []
    drawCode();
    // 绘制验证码
    function drawCode() {
        var canvas = document.getElementById("verifyCanvas"); //获取HTML端画布
        var context = canvas.getContext("2d"); //获取画布2D上下文
        context.fillStyle = "cornflowerblue"; //画布填充色
        context.fillRect(0, 0, canvas.width, canvas.height);
        // 创建渐变
        var gradient = context.createLinearGradient(0, 0, canvas.width, 0);
        gradient.addColorStop("0", "magenta");
        gradient.addColorStop("0.5", "blue");
        gradient.addColorStop("1.0", "red");
        //清空画布
        context.fillStyle = gradient; //设置字体颜色
        context.font = "25px Arial"; //设置字体
        //var rand = new Array();
        var x = new Array();
        var y = new Array();
        for (var i = 0; i < 4; i++) {
            rand[i] = nums[Math.floor(Math.random() * nums.length)]
            x[i] = i * 16 + 10;
            y[i] = Math.random() * 20 + 20;
            context.fillText(rand[i], x[i], y[i]);
        }
        // console.log(rand);
        //画3条随机线
        for (var i = 0; i < 3; i++) {
            drawline(canvas, context);
        }

        // 画30个随机点
        for (var i = 0; i < 30; i++) {
            drawDot(canvas, context);
        }
        convertCanvasToImage(canvas)
    }

    // 随机线
    function drawline(canvas, context) {
        context.moveTo(Math.floor(Math.random() * canvas.width), Math.floor(Math.random() * canvas.height)); //随机线的起点x坐标是画布x坐标0位置，y坐标是画布高度的随机数
        context.lineTo(Math.floor(Math.random() * canvas.width), Math.floor(Math.random() * canvas.height)); //随机线的终点x坐标是画布宽度，y坐标是画布高度的随机数
        context.lineWidth = 0.5; //随机线宽
        context.strokeStyle = 'rgba(50,50,50,0.3)'; //随机线描边属性
        context.stroke(); //描边，即起点描到终点
    }
    // 随机点(所谓画点其实就是画1px像素的线，方法不再赘述)
    function drawDot(canvas, context) {
        var px = Math.floor(Math.random() * canvas.width);
        var py = Math.floor(Math.random() * canvas.height);
        context.moveTo(px, py);
        context.lineTo(px + 1, py + 1);
        context.lineWidth = 0.2;
        context.stroke();

    }
    // 绘制图片
    function convertCanvasToImage(canvas) {
        document.getElementById("verifyCanvas").style.display = "none";
        var image = document.getElementById("code_img");
        image.src = canvas.toDataURL("image/png");
        return image;
    }

    // 点击图片刷新
    document.getElementById('code_img').onclick = function () {
        $('#verifyCanvas').remove();
        $('#verify').after('<canvas width="100" height="40" id="verifyCanvas"></canvas>')
        drawCode();
    }
</script>

</html>