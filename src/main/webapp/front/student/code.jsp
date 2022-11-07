<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String base = request.getContextPath() + "/";
  String url = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + base;
%>

<head>
  <base href="<%=url%>">
  <title>学生页</title>
  <script src="./jquery/jquery-1.11.1-min.js"></script>
  <%--文件上传--%>
  <script type="text/javascript" src="./js/ajaxfileupload.js"></script>
  <title>双码上传</title>
  <style>

    /*input[type="file"] {
      color: transparent;
      margin-left: 100px;
    }*/

    .left {
      position: absolute;
      top: 50%;
      left: 50%;
      width: 300px;
      height: 400px;
      margin-right: 50px;
      translate: -370px -200px;
      /* background-color: pink; */
      border: 1px solid #ccc;
    }

    .left img {
      width: 100%;
      height: 100%;
    }

    #healthCode {
      position: absolute;
      bottom: 13%;
      left: 28%;
    }

    .right {
      position: absolute;
      top: 50%;
      right: 50%;
      width: 300px;
      height: 400px;
      translate: 340px -200px;
      margin-left: 50px;
      border: 1px solid #ccc;
    }

    .right img {
      width: 100%;
      height: 100%;
    }

    #tourCode {
      position: absolute;
      bottom: 13%;
      left: 58%;
    }
  </style>
</head>

<script type="text/javascript">

  $(function () {
      $.ajax({
        url : "student/queryStudentById.do",
        data : {
          id:"${sessionScope.sessionStudent.id}",
        },
        type : "post",
        dataType : "json",
        success : function (data) {
          $('#healthCodeImg').attr('src', "upload/"+data.retData.healthCode);
          $('#tourCodeImg').attr('src', "upload/"+data.retData.tourCode);
        }
    });
  });

  function fileChange(){
    $.ajaxFileUpload({
      url: "student/ajaxHealthCodeImage.do", //用于文件上传的服务器端请求地址
      secureuri: false, //安全协议，一般设置为false
      fileElementId: "healthCode",//文件上传控件的id属性  <input type="file" id="healthCode" name="healthCodeImage" />
      dataType: "json",
      success: function (data) {
        if (data.code == "200"){
          alert(healthCode)
          $.ajax({
            url : "student/setHealthCode.do",
            data : {
              id:"${sessionScope.sessionStudent.id}",
              healthCode:healthCode
            },
            type : "post",
            dataType : "json",
            success : function (data) {
            }
          })
          $('#healthCodeImg').attr('src', "upload/"+data.retData);
        } else {
          layer.alert(data.message, {icon: 7});
        }
      }
    });
  }

  function fileChange2(){
    $.ajaxFileUpload({
      url: "student/ajaxTourCodeImage.do", //用于文件上传的服务器端请求地址
      secureuri: false, //安全协议，一般设置为false
      fileElementId: "tourCode",//文件上传控件的id属性  <input type="file" id="tourCode" name="tourCodeImage" />
      dataType: "json",
      success: function (data) {
        var tourCode = data.retData;
        if (data.code == "200") {
          $.ajax({
            url : "student/setTourCode.do",
            data : {
              id:"${sessionScope.sessionStudent.id}",
              tourCode:tourCode
            },
            type : "post",
            dataType : "json",
            success : function (data) {

            }
          })
          $('#tourCodeImg').attr('src', "upload/"+data.retData);
        } else {
          layer.alert(data.message, {icon: 7});
        }
      }
    });
  }

</script>

<body>
  <div>
    <input type="file" id="healthCode" name="healthCodeImage" accept="image/jpg,image/png,image/jpeg,image/bmp" onchange="fileChange()"/>
    <!--文件上传选择按钮-->
    <div class="left">
      <img id="healthCodeImg" src="" />
    </div>
  </div>
  <div>
    <input type="file" id="tourCode" name="tourCodeImage" accept="image/jpg,image/png,image/jpeg,image/bmp" onchange="fileChange2()" />
    <!--文件上传选择按钮-->
    <div class="right">
      <img id="tourCodeImg" src="" />
    </div>
  </div>
</body>

</html>

