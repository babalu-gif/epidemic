<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String base = request.getContextPath() + "/";
String url = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + base;
%>

<head>
  <base href="<%=url%>">
  <title>学生页</title>
  <link rel="stylesheet" href="./css/index.css" />
  <link rel="stylesheet" href="./jquery/bootstrap_3.3.0/css/bootstrap.min.css">
  <script type="text/javascript" src="./jquery/jquery-1.11.1-min.js"></script>
  <script type="text/javascript" src="./jquery/bootstrap.js"></script>
  <script type="text/javascript" src="./jquery/layer-3.5.1/layer.js"></script>
  <%--文件上传--%>
  <script type="text/javascript" src="./js/ajaxfileupload.js"></script>
</head>

<style>
  input[type="file"] {
    color: transparent;
    margin-left: 100px;
  }
</style>

<script type="text/javascript">

  $(function (){

    // 为退出按钮添加单击事件
    $("#logoutBtn").click(function (){
      window.location.href="admin/logout.do";
    });

    // 显示修改密码的模态窗口
    $("#editPwdModalBtn").click(function (){
      $("#editPwdModal").modal("show");
    })

    // 为更新按钮绑定单击事件
    $("#updatePwdBtn").click(function () {
      var oldPwd = $.trim($("#oldPwd").val());
      var newPwd = $.trim($("#newPwd").val());
      var confirmPwd = $.trim($("#confirmPwd").val());

      // 表单验证
      if (oldPwd != "${sessionScope.sessionStudent.password}"){
        layer.alert("原密码输入错误", {icon: 7});
        return;
      }
      if (newPwd == ""){
        layer.alert("新密码不能为空", {icon: 7});
        return;
      }
      if (newPwd == oldPwd){
        layer.alert("新密码不能和原密码一样", {icon: 7});
        return;
      }
      if (newPwd != confirmPwd){
        layer.alert("新密码和确认的密码不一致", {icon: 7});
        return;
      }

      $.ajax({
        url:"student/updatePwd.do",
        data:{
          id:"${sessionScope.sessionStudent.id}",
          password:newPwd
        },
        type:"post",
        dataType:"json",
        success:function (data) {
          if (data.code == "200"){
            window.location.href="admin/logout.do";
          }
          if (data.code == "400"){
            layer.alert(data.message, {icon: 5});
          }
        }
      })
    });

    // 为“修改头像”模态窗口添加单击事件
    $("#editAvatarModalBtn").click(function () {

      $.ajax({
        url:"student/queryStudentById.do",
        data:{
          id:"${sessionScope.sessionStudent.id}"
        },
        type:"post",
        dataType:"json",
        success:function (data){
          $("#updateImgName").html(data.retData.avatar);
          $("#updateImgDiv").empty();  //清空原有数据
          //创建一个图片的标签
          var imgObj = $("<img>");
          //给img标签对象追加属性
          imgObj.attr("src", "upload/" + data.retData.avatar);
          imgObj.attr("style", "width:150px;height:150px;border-radius:50%;");
          //将图片img标签追加到imgDiv末尾
          $("#updateImgDiv").append(imgObj);

        }
      })

      // 展现修改学生的模态窗口
      $("#editAvatarModal").modal("show");
    });

    // 为修改头像模态窗口的“更新”按钮绑定单击事件
    $("#updateAvatarBtn").click(function () {

      var avatar = $("#updateImgName").html();
      $.ajax({
        url : "student/setAvatar.do",
        data : {
          id:"${sessionScope.sessionStudent.id}",
          avatar:avatar
        },
        type : "post",
        dataType : "json",
        success : function (data) {
          if (data.code == "200"){
            layer.alert(data.message, {icon:6});
            var teacherAvatar = document.getElementById("avatar");
            teacherAvatar.src = "upload/"+avatar;
            // 关闭模态窗口
            $("#editAvatarModal").modal("hide");
          } else {
            layer.alert(data.message, {icon:5});
          }
        }
      })
    });

    // 为“打卡”按钮添加单击事件
    $("#punchBtn").click(function () {

      $.ajax({
        url : "student/punch.do",
        data : {
          id:"${sessionScope.sessionStudent.id}"
        },
        type : "post",
        dataType : "json",
        success : function (data) {
          if (data.code == "200"){
            layer.alert(data.message, {icon:6});

            var ps = document.getElementById("punchState");
            ps.setAttribute("style", "");
            ps.innerHTML="已打卡";

            // 关闭模态窗口
            $("#punchModal").modal("hide");
          } else {
            layer.alert(data.message, {icon:5});
          }
        }
      })
    });


  });

  function fileChange() {//注意：此处不能使用jQuery中的change事件，因为仅触发一次，因此使用标签的：onchange属性
    $.ajaxFileUpload({
      url: "student/ajaxImg.do", //用于文件上传的服务器端请求地址
      secureuri: false, //安全协议，一般设置为false
      fileElementId: "updateAvatar",//文件上传控件的id属性  <input type="file" id="updateAvatar" name="studentImage" />
      dataType: "json",
      success: function (data) {
        if (data.code == "200") {
          $("#updateImgDiv").empty();  //清空原有数据
          //创建一个图片的标签
          var imgObj = $("<img>");
          //给img标签对象追加属性
          imgObj.attr("src", "upload/" + data.retData);
          imgObj.attr("style", "width:150px;height:150px;border-radius:50%;");
          //将图片img标签追加到imgDiv末尾
          $("#updateImgDiv").append(imgObj);
          // 将图片的名称赋值给文本框
          $("#updateImgName").html(data.retData);
        } else {
          layer.alert(data.message, {icon: 7});
        }
      }
    });
  }

  function punch(){
    $("#punchModal").modal("show");
  }

</script>

<body>
  <!-- 我的资料 -->
  <div class="modal fade" id="myInformation" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">
            <span aria-hidden="true">×</span>
          </button>
          <h4 class="modal-title">我的资料</h4>
        </div>
        <div class="modal-body">
          <div style="position: relative; left: 40px;">
            姓名：<b>${sessionScope.sessionStudent.name}</b><br><br>
            学号：<b>${sessionScope.sessionStudent.id_number}</b><br><br>
            邮箱：<b>${sessionScope.sessionStudent.email}</b><br><br>
            电话：<b>${sessionScope.sessionStudent.phone}</b><br><br>
            性别：<b>${sessionScope.sessionStudent.sex}</b><br><br>
            住址：<b>${sessionScope.sessionStudent.address}</b><br><br>
            系部：<b>${sessionScope.sessionStudent.dep_id}</b><br><br>
            班级：<b>${sessionScope.sessionStudent.class_id}</b><br><br>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
        </div>
      </div>
    </div>
  </div>

  <!-- 打卡的模态窗口 -->
  <div class="modal fade" id="punchModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 40%;">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">
            <span aria-hidden="true">×</span>
          </button>
          <h4 class="modal-title">打卡</h4>
        </div>

        <input type="button" id="punchBtn" value="打卡">

        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
        </div>
      </div>
    </div>
  </div>

  <!-- 修改头像的模态窗口 -->
  <div class="modal fade" id="editAvatarModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 40%;">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">
            <span aria-hidden="true">×</span>
          </button>
          <h4 class="modal-title">修改头像</h4>
        </div>
        <div class="form-group">
          <label class="col-sm-2 control-label">头像<span style="font-size: 50px; color: red;"></span></label>
          <td> <br><div id="updateImgDiv" style="display:block; width: 40px; height: 50px;"></div><br><br><br><br><br><br>
            <input type="file" id="updateAvatar" name="studentImage" accept="image/jpg,image/png,image/jpeg,image/bmp" onchange="fileChange()">
            <span id="updateImgName" >未选择文件...</span><br>
          </td>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
          <button id="updateAvatarBtn" type="button" class="btn btn-primary">更新</button>
        </div>
      </div>
    </div>
  </div>

  <!-- 修改密码的模态窗口 -->
  <div class="modal fade" id="editPwdModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 70%;">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">
            <span aria-hidden="true">×</span>
          </button>
          <h4 class="modal-title">修改密码</h4>
        </div>
        <div class="modal-body">
          <form class="form-horizontal" role="form">
            <div class="form-group">
              <label for="oldPwd" class="col-sm-2 control-label">原密码</label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="password" class="form-control" id="oldPwd" style="width: 200%;">
              </div>
            </div>

            <div class="form-group">
              <label for="newPwd" class="col-sm-2 control-label">新密码</label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="password" class="form-control" id="newPwd" style="width: 200%;">
              </div>
            </div>

            <div class="form-group">
              <label for="confirmPwd" class="col-sm-2 control-label">确认密码</label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="password" class="form-control" id="confirmPwd" style="width: 200%;">
              </div>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
          <button id="updatePwdBtn" type="button" class="btn btn-primary">更新</button>
        </div>
      </div>
    </div>
  </div>
  
  <!-- 退出系统的模态窗口 -->
  <div class="modal fade" id="exitModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">
            <span aria-hidden="true">×</span>
          </button>
          <h4 class="modal-title">离开</h4>
        </div>
        <div class="modal-body">
          <p>您确定要退出系统吗？</p>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
          <button type="button" class="btn btn-primary" id="logoutBtn">确定</button>
        </div>
      </div>
    </div>
  </div>

  <div class="box">
    <div class="box-head">
      <span class="headleft">
        <span class="glyphicon glyphicon-heart-empty"></span> 智慧校园</span>
      <span class="headright">
        <!-- Split button -->
         <div class="btn-group" style="float: right;right: 150px;top: 15px">
           <c:if test="${sessionScope.sessionStudent.isClock eq '0'}">
             <span id="punchState" style="color: #0078ff" class="glyphicon" onclick="punch()">未打卡</span>
           </c:if>
           <c:if test="${sessionScope.sessionStudent.isClock eq '1'}">
             <span id="punchState" class="glyphicon">已打卡</span>
           </c:if>
         </div>
        <div class="btn-group" style="float: right;right: 40px;top: -5px;display: flex">

          <button type="button" class="btn btn-default" style="flex: auto">
            <span class="glyphicon glyphicon-user"></span>${sessionScope.sessionStudent.name}
          </button>
          <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true"
            aria-expanded="false">
            <span class="caret"></span>
            <span class="sr-only">Toggle Dropdown</span>
          </button>
          <ul class="dropdown-menu">
            <li><a href="javascript:void(0)"  data-toggle="modal" data-target="#myInformation"><span class="glyphicon glyphicon-file"></span> 我的资料</a></li>
            <li><a id="editAvatarModalBtn" href="javascript:void(0)" data-toggle="modal"><span class="glyphicon glyphicon-edit"></span>修改头像</a></li>
            <li><a href="javascript:void(0)" data-toggle="modal" id="editPwdModalBtn"><span class="glyphicon glyphicon-edit"></span> 修改密码</a></li>
            <li role="separator" class="divider"></li>
            <li><a href="javascript:void(0);" data-toggle="modal" data-target="#exitModal">退出</a></li>
          </ul>
        </div>
      </span>
    </div>
    <div class="box-body">
      <div class="body-left">
        <div id="ltop">
          <div id="lts">
            <img style="width:150px;height:150px;border-radius:50%;" type="file" id="avatar" name="image" src="upload/${sessionScope.sessionStudent.avatar}" /><br/><br/>
          </div>
        </div>
        <div id="lbottom">
          <ul class="nav nav-pills nav-stacked">
            <li><a href="admin/toState.do" target="workareaFrame">疫情状态发布</a></li>
            <li><a href="student/toCode.do" target="workareaFrame">双码提交</a></li>
            <li><a href="student/toLeave.do" target="workareaFrame">请假申请(带请假记录)</a></li>
          </ul>
        </div>
        <!-- 分割线 -->
        <div id="divider1"></div>
      </div>
      <div class="body-right">
        <iframe style="border-width: 0px; width: 100%; height: 600px;" name="workareaFrame" src="https://voice.baidu.com/act/newpneumonia/newpneumonia/?from=osari_pc_3#tab1" >
        </iframe>
      </div>
    </div>
  </div>
</body>

</html>