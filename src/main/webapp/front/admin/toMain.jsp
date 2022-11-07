<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String base = request.getContextPath() + "/";
String url = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + base;
%>

<head>
  <base href="<%=url%>">
  <title>管理员页</title>
  <link rel="stylesheet" href="./css/index.css" />
  <link rel="stylesheet" href="./jquery/bootstrap_3.3.0/css/bootstrap.min.css">
  <script type="text/javascript" src="./jquery/jquery-1.11.1-min.js"></script>
  <script type="text/javascript" src="./jquery/bootstrap.js"></script>
  <script type="text/javascript" src="./jquery/layer-3.5.1/layer.js"></script>
</head>

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
      if (oldPwd != "${sessionScope.sessionUser.password}"){
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
        url:"admin/updatePwd.do",
        data:{
          id:"${sessionScope.sessionUser.id}",
          password:newPwd
        },
        type:"post",
        dataType:"json",
        success:function (data) {
          if (data.code == "200"){
            window.location.href="admin/logout.do";
          }
          if (data.code == "304"){
            layer.alert(data.message, {icon: 5});
          }
        }
      })
    });






  });

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
            姓名：<b>${sessionScope.sessionUser.name}</b><br><br>
            登录帐号：<b>${sessionScope.sessionUser.account}</b><br><br>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
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
        <div class="btn-group"  style="float: right;right: 40px;top: 10px;display: flex">
          <button type="button" class="btn btn-default" style="flex: auto">
            <span class="glyphicon glyphicon-user">${sessionScope.sessionUser.name}</span></button>
          <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true"
            aria-expanded="false">
            <span class="caret"></span>
            <span class="sr-only">Toggle Dropdown</span>
          </button>
          <ul class="dropdown-menu">
            <li><a href="#" ><span
                  class="glyphicon glyphicon-wrench"></span> 系统设置</a></li>
            <li><a href="javascript:void(0)"  data-toggle="modal" data-target="#myInformation"><span class="glyphicon glyphicon-file"></span> 我的资料</a></li>
            <li><a href="javascript:void(0)" data-toggle="modal" id="editPwdModalBtn"><span class="glyphicon glyphicon-edit"></span> 修改密码</a></li>
            <li role="separator" class="divider"></li>
            <li><a href="javascript:void(0);" data-toggle="modal" data-target="#exitModal">退出</a></li>
          </ul>
        </div>
      </span>
    </div>
    <div class="box-body">
      <div class="body-left">
        <ul class="nav nav-pills nav-stacked">
          <li><a href="admin/toState.do" target="workareaFrame">疫情状态发布</a></li>
<%--          <li><a href="https://voice.baidu.com/act/newpneumonia/newpneumonia/?from=osari_pc_3#tab1" target="workareaFrame">疫情状态发布</a></li>--%>
          <li><a href="admin/toHealthPunch.do" target="workareaFrame">健康打卡统计分析</a></li>
          <%--<li><a href="javascript:void(0);" target="workareaFrame">异常上报及统计</a></li>--%>
          <li><a href="admin/toLeave.do" target="workareaFrame">请假申请及返校审核</a></li>
          <li><a href="admin/toTeacher.do" target="workareaFrame">教师信息</a></li>
          <li><a href="admin/toStudent.do" target="workareaFrame">学生信息</a></li>
          <!-- <li><a href="javascript:void(0);" target="workareaFrame">患者同行查询</a></li> -->
        </ul>
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