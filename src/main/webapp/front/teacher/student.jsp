<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  String base = request.getContextPath() + "/";
  String url = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + base;
%>

<head>
  <title>学生信息</title>
  <link href=".././jquery/bootstrap_3.3.0/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
  <script type="text/javascript" src=".././js/jquery-2.1.1.min.js"></script>
  <script type="text/javascript" src=".././jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
  <script type="text/javascript" src=".././jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.min.js"></script>
  <script type="text/javascript" src=".././jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
  <%--导入分页插件--%>
  <link type="text/css" href=".././jquery/bs_pagination/jquery.bs_pagination.min.css"/>
  <script src=".././jquery/bs_pagination/en.js"></script>
  <script src=".././jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
  <%--layer插件--%>
  <script type="text/javascript" src=".././jquery/layer-3.5.1/layer.js"></script>
  <%--文件上传--%>
  <script type="text/javascript" src=".././js/ajaxfile../upload.js"></script>
</head>

<style>
  input[type="file"] {
    color: transparent;
    margin-left: 100px;
  }
</style>

<script type="text/javascript">

  $(function () {

    //定制字段
    $("#definedColumns > li").click(function (e) {
      //防止下拉菜单消失
      e.stopPropagation();
    });

    // 为全选按钮触发事件
    $("#qx").click(function () {
      $("input[name=xz]").prop("checked", this.checked);
    })

    /*
        动态生成的元素（不能以普通绑定事件的形式来进行操作），我们要以on方法的形式来触发事件
        语法格式：$(需要绑定事件的外层元素).on("绑定事件的方式", 需要绑定的jquery对象, 回调函数)
     */
    $("#studentBody").on("click", $("input[name=xz]"), function () {
      $("#qx").prop("checked", $("input[name=xz]").length==$("input[name=xz]:checked").length);
    });

    refresh(1, 2);

    // 为“查询”按钮添加单击事件
    $("#searchStudentBtn").click(function () {
      refresh(1, 2);
    });

    // 为“导出所有”按钮添加单击事件
    $("#exportStudentAllBtn").click(function () {
      // 发送同步请求
      window.location.href="exportAllStudents.do?ci=${sessionScope.sessionTeacher.class_id}";
    })


    // 为“选择导出”按钮添加单击事件
    $("#exportStudentCheckedBtn").click(function () {
      // 找到复选框所有挑√的复选框的jquery对象
      var $check = $("input[name=xz]:checked");
      if ($check.length == 0){
        layer.alert("请选择需要导出的学生", {icon:7})
      } else {
        var param = [];
        for(var i = 0; i < $check.length; i++) {
          // 将勾选的出来的学生id以','分割放入数组中
          param.push($($check[i]).val());
        }

        $("#qx").prop("checked", false);
        // 发送同步请求
        window.location.href="exportCheckedStudent.do?id="+param;
      }
    });


  });

  // 定义一个函数，发送请求不同页码对应的数据
  function refresh(page, pageSize) {
    // 将全选按钮框的√去掉
    $("#qx").prop("checked", false);

    // 将查询文本框的信息存储到隐藏域中，方便进行查询操作
    $("#hidden_id").val($.trim($("#search_id").val()));
    $("#hidden_id_number").val($.trim($("#search_id_number").val()));
    $("#hidden_name").val($.trim($("#search_name").val()));
    $("#hidden_sex").val($.trim($("#search_sex").val()));
    $("#hidden_phone").val($.trim($("#search_phone").val()));
    $("#hidden_class_id").val($.trim($("#search_class_id").val()));

    $.post("getStudentByTeacherClassId.do", {
      "page": page,
      "pageSize": pageSize,
      "name" : $("#hidden_name").val(),
      "id_number" : $("#hidden_id_number").val(),
      "sex" : $("#hidden_sex").val(),
      "phone" : $("#hidden_phone").val(),
      "class_id" : $("#hidden_class_id").val(),
      "ci" : "${sessionScope.sessionTeacher.class_id}"
    }, function (data) {

      // 清空studentBody的数据
      $("#studentBody").html("");
      var html = "";
      $.each(data.list, function(index, s) {
        html += '<tr>';
        html += '<td><input name="xz" type="checkbox" value="'+s.id+'"/></td>';
        html += '<td style="color: #0078ff" onclick="detailStudent(\''+s.id+'\')">'+s.name+'</td>';
        html += '<td>'+s.id_number+'</td>';
        html += '<td>'+s.class_id+'</td>';
        html += '<td>'+s.phone+'</td>';
        html += '<td>'+s.sex+'</td>';
        html += '</tr>';
      })
      $("#studentBody").append(html);

      //bootstrap的分页插件
      $("#studentPage").bs_pagination({
        currentPage: data.pageNum, // 页码
        rowsPerPage: data.pageSize, // 每页显示的记录条数
        maxRowsPerPage: 20, // 每页最多显示的记录条数
        totalPages: data.pages, // 总页数
        totalRows: data.total, // 总记录条数
        visiblePageLinks: 2, // 显示几个卡片
        showGoToPage: true,
        showRowsPerPage: true,
        showRowsInfo: true,
        showRowsDefaultInfo: true,
        //回调函数，用户每次点击分页插件进行翻页的时候就会触发该函数
        onChangePage: function (event, obj) {
          //currentPage:当前页码 rowsPerPage:每页记录数
          refresh(obj.currentPage, obj.rowsPerPage);
        }
      });
    }, "json")
  }

  // 为“详情”按钮绑定单击事件
  function detailStudent(studentId){
    $.ajax({
      url:"queryStudentById.do",
      data:{
        id:studentId
      },
      type:"post",
      dataType:"json",
      success:function (data){
        $("#detail_name").val(data.retData.name);
        $("#detail_idNumber").val(data.retData.id_number);
        $("#detail_email").val(data.retData.email);
        $("#detail_phone").val(data.retData.phone);
        $("#detail_sex").val(data.retData.sex);
        $("#detail_password").val(data.retData.password);
        $("#detail_dep_id").val(data.retData.dep_id);
        $("#detail_class_id").val(data.retData.class_id);
        $("#detail_lockState").val(data.retData.lockState);
        $("#detail_isClock").val(data.retData.isClock);
        $("#detailImgName").html(data.retData.avatar);
        $("#detailHealthImgName").html(data.retData.healthCode);
        $("#detailTourImgName").html(data.retData.tourCode);
        $("#detail_address").val(data.retData.address);
        $("#detailImgDiv").empty();  //清空原有数据
        //创建一个图片的标签
        var imgObj = $("<img>");
        //给img标签对象追加属性
        imgObj.attr("src", ".././upload/" + data.retData.avatar);
        imgObj.attr("style", "width:150px;height:150px;border-radius:50%;");
        //将图片img标签追加到imgDiv末尾
        $("#detailImgDiv").append(imgObj);

        $("#detailHealthImgDiv").empty();  //清空原有数据
        //创建一个图片的标签
        var imgObj = $("<img>");
        //给img标签对象追加属性
        imgObj.attr("src", ".././upload/" + data.retData.healthCode);
        imgObj.attr("style", "width:150px;height:200;");
        // imgObj.attr("style", "position: relative;width: 100%;height: 0;padding-bottom: 100%;overflow: hidden;");
        //将图片img标签追加到imgDiv末尾
        $("#detailHealthImgDiv").append(imgObj);

        $("#detailTourImgDiv").empty();  //清空原有数据
        //创建一个图片的标签
        var imgObj = $("<img>");
        //给img标签对象追加属性
        imgObj.attr("src", ".././upload/" + data.retData.tourCode);
        imgObj.attr("style", "width:150px;height:200;");
        //将图片img标签追加到imgDiv末尾
        $("#detailTourImgDiv").append(imgObj);

      }
    })

    // 展现修改学生的模态窗口
    $("#detailStudentModal").modal("show");
  }

</script>

<body style="width: 80%;">

<%--为更新文本框设置隐藏域--%>
<input type="hidden" id="hidden_id"/>
<%--为查询文本框设置隐藏域--%>
<input type="hidden" id="hidden_name"/>
<input type="hidden" id="hidden_id_number"/>
<input type="hidden" id="hidden_sex"/>
<input type="hidden" id="hidden_phone"/>
<input type="hidden" id="hidden_class_id"/>


  <!-- 学生详情的模态窗口 -->
  <div class="modal fade" id="detailStudentModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 70%;">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">
            <span aria-hidden="true">×</span>
          </button>
          <h4 class="modal-title" id="myModalLabel2">学生详细信息</h4>
        </div>
        <div class="modal-body">
          <form class="form-horizontal" role="form" id="studentDetailForm">
            <div class="form-group">
              <label for="detail_name" class="col-sm-2 control-label">姓名</label>
              <div class="col-sm-10" style="width: 250px;">
                <input type="text" class="form-control" id="detail_name" readonly>
              </div>
              <label for="detail_idNumber" class="col-sm-2 control-label">学号</label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="detail_idNumber" readonly>
              </div>
            </div>

            <div class="form-group">
              <label for="detail_address" class="col-sm-2 control-label">家庭地址</label>
              <div class="col-sm-10">
                <input type="text" class="form-control" id="detail_address" readonly>
              </div>
            </div>

            <div class="form-group">
              <label for="detail_sex" class="col-sm-2 control-label">性别</label>
              <div class="col-sm-10" style="width: 150px;">
                <select class="form-control" id="detail_sex" disabled>
                  <option value="男">男</option>
                  <option value="女">女</option>
                </select>
              </div>
              <label for="detail_lockState" class="col-sm-2 control-label">账号状态</label>
              <div class="col-sm-10" style="width: 150px;">
                <select class="form-control" id="detail_lockState" disabled>
                  <option value="1">1</option>
                  <option value="0">0</option>
                </select>
              </div>
              <label for="detail_isClock" class="col-sm-1 control-label">是否打卡</label>
              <div class="col-sm-10" style="width: 150px;">
                <select class="form-control" id="detail_isClock" disabled>
                  <option value="0">未打卡</option>
                  <option value="1">打卡</option>
                </select>
              </div>
            </div>

            <div class="form-group">
              <label for="detail_phone" class="col-sm-2 control-label">手机号</label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="detail_phone" readonly>
              </div>
            </div>
            <div class="form-group">
              <label for="detail_password" class="col-sm-2 control-label">密码</label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="detail_password" readonly>
              </div>
            </div>
            <div class="form-group" style="position: relative;">
              <label for="detail_email" class="col-sm-2 control-label">邮箱</label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="detail_email" readonly>
              </div>
            </div>

            <div class="form-group" style="position: relative;">
              <label for="detail_dep_id" class="col-sm-2 control-label">系</label>
              <div class="col-sm-10" style="width: 250px;">
                <input type="text" class="form-control" id="detail_dep_id" readonly>
              </div>
              <label for="detail_class_id" class="col-sm-2 control-label">班级</label>
              <div class="col-sm-10" style="width: 250px;">
                <input type="text" class="form-control" id="detail_class_id" readonly>
              </div>
            </div>

            <div class="form-group" style="position: relative;">
              <label for="detailImgDiv" class="col-sm-2 control-label">头像<span style="font-size: 15px; color: red;"></span></label>
              <td style="margin-left: 8%">
                <br><div id="detailImgDiv" style="display:block; width: 40px; height: 50px;"></div>
                <br><br><br><br><br><br>
                <input type="file" id="detailAvatar" name="teacherImage" accept="image/jpg,image/png,image/jpeg,image/bmp" disabled>
                <span style="margin-left: 100px" id="detailImgName">未选择文件...</span><br>
              </td>
            </div>

            <div class="form-group">
                <div class="col-sm-10" style="width: 250px;">
                <td style="margin-left: 8%">
                    <br><div id="detailHealthImgDiv" style="display:block; width: 40px; height: 50px;"></div>
                    <br><br><br><br><br><br>
                    <input type="file" id="detailHealthAvatar" name="teacherImage" accept="image/jpg,image/png,image/jpeg,image/bmp" disabled>
                    <span style="margin-left: 100px" id="detailHealthImgName">未选择文件...</span><br>
                </td>
                </div>
                <div class="col-sm-10" style="width: 250px;">
                <td style="margin-left: 8%">
                    <br><div id="detailTourImgDiv" style="display:block; width: 40px; height: 50px;"></div>
                    <br><br><br><br><br><br>
                    <input type="file" id="detailTourAvatar" name="teacherImage" accept="image/jpg,image/png,image/jpeg,image/bmp" disabled>
                    <span style="margin-left: 100px" id="detailTourImgName">未选择文件...</span><br>
                </td>
                </div>
            </div>
          </form>

        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
        </div>
      </div>
    </div>
  </div>

  <!-- 页面布局 -->
  <div>
    <div style="position: relative; left: 0; top: -10px;">
      <div class="page-header">
        <h3>学生列表</h3>
      </div>
    </div>
  </div>

  <div style="position: relative; top: -20px; left: 0; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

      <div class="btn-toolbar" role="toolbar" style="height: 80px;">
        <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
          <div class="form-group">
            <div class="input-group" style="width:210px">
              <div class="input-group-addon">学号</div>
              <input id="search_id_number" class="form-control" type="text">
            </div>
          </div>
          <div class="form-group">
            <div class="input-group" style="width:150px">
              <div class="input-group-addon">姓名</div>
              <input id="search_name" class="form-control" type="text">
            </div>
          </div>
          <div class="form-group">
            <div class="input-group" style="width: 200px;">
              <div class="input-group-addon">班级</div>
              <input id="search_class_id" class="form-control" type="text">
            </div>
          </div>
          <div class="form-group">
            <div class="input-group" style="width:160px">
              <div class="input-group-addon">性别</div>
              <select class="form-control" type="text" id="search_sex">
                <option value=""></option>
                <option value="男">男</option>
                <option value="女">女</option>
              </select>
            </div>
          </div>
          <div class="form-group">
            <div class="input-group" style="width:210px">
              <div class="input-group-addon">手机号</div>
              <input id="search_phone" class="form-control" type="text">
            </div>
          </div>
          <br>


          <button id="searchStudentBtn" type="button" class="btn btn-primary" style="position: relative; top:25px;left:45%;width:100px;">查询</button>

        </form>
      </div>

      <div class="btn-toolbar" role="toolbar"
           style="background-color: #F7F7F7; height: 50px; position: relative;top: 60px;">
        <div class="btn-group" style="position: relative; top: 18%;">
          <div class="btn-group" style="position: relative; top: 18%;">
            <button id="exportStudentAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
            <button id="exportStudentCheckedBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
          </div>
        </div>
      </div>

      <div style="position: relative;top: 80px">
        <table class="table table-hover">
          <thead>
            <tr style="color: #B3B3B3;">
              <td><input id="qx" type="checkbox" /></td>
              <td>姓名</td>
              <td>学号</td>
              <td>班级</td>
              <td>手机号</td>
              <td>性别</td>
            </tr>
          </thead>
          <tbody id="studentBody">

          </tbody>
        </table>

        <footer class="message_footer">
          <nav>
            <%--分页插件--%>
            <div  style="height: 50px; position: relative;top: 30px;">
              <div id="studentPage"></div>
            </div>
          </nav>
        </footer>
      </div>
    </div>

  </div>
</body>

</html>