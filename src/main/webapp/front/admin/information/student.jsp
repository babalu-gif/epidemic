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
  <script type="text/javascript" src=".././js/ajaxfileupload.js"></script>
  <%--自动补全--%>
  <script type="text/javascript" src=".././jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>
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

    // 为保存按钮绑定事件，执行添加操作
    $("#saveStudentBtn").click(function (){
      var name = $.trim($("#create_name").val());
      var phone = $.trim($("#create_phone").val());
      var email = $.trim($("#create_email").val());
      var class_id = $.trim($("#create_class_id").val());
      var sex =  $.trim($("#create_sex").val())
      var address  = $.trim($("#create_address").val());
      var dep_id  = $.trim($("#create_dep").val());

      // 表单验证
      if (name == ""){
        layer.alert("名字不能为空", {icon:7});
        return;
      }

      var phoneTrue = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
      if (!phoneTrue.test(phone)){
        layer.alert("手机号格式有误", {icon:7});
        return;
      }

      var emailTrue = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
      if (!emailTrue.test(email)){
        layer.alert("邮箱格式有误", {icon:7});
        return;
      }


      $.ajax({
        url : "student/saveStudent.do",
        data : {
          "name" : name,
          "address" : address,
          "phone" : phone,
          "email" : email,
          "class_id" : class_id,
          "dep_id" : dep_id,
          "sex" : sex,
          "avatar" : $("#imgName").html()
        },
        type : "post",
        dataType:"json",
        success : function (data) {
          if (data.code == "200"){
            layer.alert(data.message, {icon:6});
            // 清空添加模态窗口的数据
            $("#createStudentForm")[0].reset();
            // 关闭模态窗口
            $("#createStudentModal").modal("hide");
            /*
                添加成功后，回到第一页，维持每页展示对的记录数
            */
            refresh(1, $("#studentPage").bs_pagination('getOption', 'rowsPerPage'));
          } else {
            layer.alert(data.message, {icon:5});
          }

        }
      })
    });

    // 为“删除”按钮添加单击事件
    $("#deleteStudentBtn").click(function () {
        // 找到复选框所有挑√的复选框的jquery对象
        var $xz = $("input[name=xz]:checked");
        if($xz.length == 0) {
            layer.alert("请选择需要删除的记录", {icon:0});
        }
        else {
            var param = [];
            for(var i = 0; i < $xz.length; i++) {
                // 将查询出来的试题id以','分割放入数组中
                param.push($($xz[i]).val());
            }
            // confirm 取消不删除，确定开始执行删除操作
            if(confirm("确定删除所选中的记录吗？")) {
                $.ajax({
                    url : "student/deleteStudentByIds.do?ids="+param,
                    type : "post",
                    dataType : "json",
                    success : function (data) {
                        if (data.code == "200"){
                            layer.alert(data.message, {icon:6});
                            /*
                                删除成功后，回到第一页，维持每页展示对的记录数
                             */
                            refresh(1, $("#studentPage").bs_pagination('getOption', 'rowsPerPage'));
                        }else {
                            layer.alert(data.message, {icon:2});
                        }

                    }
                })
            }
        }
    });

    // 为“修改”按钮添加单击事件
    $("#updateStudentBtn").click(function () {
      var $check = $("input[name=xz]:checked");
      if ($check.length == 0){
        layer.alert("请选择需要修改的学生", {icon:7})
        return;
      }
      if ($check.length > 1){
        layer.alert("每次只能选择一个学生", {icon:7})
        return;
      }

      var id = $check[0].value;
      $.ajax({
        url:"student/queryStudentById.do",
        data:{
          id:id
        },
        type:"post",
        dataType:"json",
        success:function (data){
          $("#hidden_id").val(data.retData.id);
          $("#update_name").val(data.retData.name);
          $("#update_email").val(data.retData.email);
          $("#update_phone").val(data.retData.phone);
          $("#update_sex").val(data.retData.sex);
          $("#update_lockState").val(data.retData.lockState);
          $("#update_isClock").val(data.retData.isClock);
          $("#update_password").val(data.retData.password);
          $("#update_class_id").val(data.retData.class_id);
          $("#update_dep").val(data.retData.dep_id);
          $("#updateImgName").html(data.retData.avatar);
          $("#update_address").val(data.retData.address);
          $("#updateImgDiv").empty();  //清空原有数据
          // 模拟用户改变select的onchange事件
          $("#update_dep").trigger("change");
          //创建一个图片的标签
          var imgObj = $("<img>");
          //给img标签对象追加属性
          imgObj.attr("src", ".././upload/" + data.retData.avatar);
          imgObj.attr("style", "width:150px;height:150px;border-radius:50%;");
          //将图片img标签追加到imgDiv末尾
          $("#updateImgDiv").append(imgObj);

        }
      })

      // 展现修改学生的模态窗口
      $("#editStudentModal").modal("show");
    });


    // 为修改学生模态窗口的"保存"按钮添加单击事件
    $("#saveUpdateStudentBtn").click(function () {
      var id = $.trim($("#hidden_id").val());
      var name = $.trim($("#update_name").val());
      var email = $.trim($("#update_email").val());
      var phone = $.trim($("#update_phone").val());
      var sex = $.trim($("#update_sex").val());
      var lockState = $.trim($("#update_lockState").val());
      var isClock = $.trim($("#update_isClock").val());
      var password = $.trim($("#update_password").val());
      var dep_id = $.trim($("#update_dep").val());
      var class_id = $.trim($("#update_class_id").val());
      var address = $.trim($("#update_address").val());
      var avatar = $("#updateImgName").html();


      // 表单验证
      if (name == ""){
        layer.alert("名字不能为空", {icon:7});
        return;
      }

      if (password == ""){
        layer.alert("密码不能为空", {icon:7});
        return;
      }

      var phoneTrue = /^(13[0-9]|14[5|7]|15[0|1|2|3|5|6|7|8|9]|18[0|1|2|3|5|6|7|8|9])\d{8}$/;
      if (!phoneTrue.test(phone)){
        layer.alert("手机号格式有误", {icon:7});
        return;
      }

      var emailTrue = /^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/;
      if (!emailTrue.test(email)){
        layer.alert("邮箱格式有误", {icon:7});
        return;
      }

      /*if (class_id == ""){
        layer.alert("班级不能为空", {icon:7});
        return;
      }*/

      $.ajax({
        url : "student/updateStudent.do",
        data : {
          "id" : id,
          "name" : name,
          "address" : address,
          "class_id" : class_id,
          "password" : password,
          "sex" : sex,
          "email" : email,
          "phone" : phone,
          "avatar" : avatar,
          "lockState" : lockState,
          "isClock" : isClock,
          "dep_id" : dep_id
        },
        type : "post",
        dataType : "json",
        success : function (data) {
          if (data.code == "200"){
            layer.alert(data.message, {icon:6});
            // 清空修改模态窗口的数据
            $("#studentUpdateForm")[0].reset();
            // 关闭模态窗口
            $("#editStudentModal").modal("hide");
            /*
                修改操作后，应该维持在当前页，维持每页展示的记录数
            */
            refresh($("#studentPage").bs_pagination('getOption', 'currentPage')
                    ,$("#studentPage").bs_pagination('getOption', 'rowsPerPage'));
          } else {
            layer.alert(data.message, {icon:5});
          }
        }
      })
    });


    // 为“导出所有”按钮添加单击事件
    $("#exportStudentAllBtn").click(function () {
      // 发送同步请求
      window.location.href="student/exportAllStudents.do";
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
        window.location.href="student/exportCheckedStudent.do?id="+param;
      }
    });

      // 给“批量导入”按钮绑定单击事件,展现导入文件的模态窗口
      $("#importStudentModalBtn").click(function () {
          $("#importStudentModal").modal("show");
      });

      // 给导入文件的模态窗口的”关闭“按钮绑定单击事件
      $("#closeImportStudentBtn2").click(function () {
          $("#selectFileName").html("未选择文件...")
          $("#importStudentModal").modal("hide");
      });

      // 给导入文件的模态窗口的”关闭“按钮绑定单击事件
      $("#closeImportStudentBtn").click(function () {
          $("#selectFileName").html("未选择文件...")
          $("#importStudentModal").modal("hide");
      });

      // 给“导入”按钮添加单击事件
      $("#importStudentBtn").click(function (){
          // 收集参数
          var studentFile = $("#studentFile")[0].files[0];

          // FormData是ajax提供的接口，可以模拟键值对向后台提交参数
          // ForData最大的优势是不仅可以提交文本数据，还可以提交二进制数据
          var formData = new FormData();
          formData.append("studentFile", studentFile);
          // 发送请求
          $.ajax({
              url:"student/importStudents.do",
              data:formData,
              type:"post",
              dataType:"json",
              processData: false, // processData处理数据
              contentType: false, // contentType发送数据的格式
              success:function (data){
                  if (data.code == "200"){
                      layer.alert(data.message, {icon:6});
                      // 关闭模态窗口
                      $("#importStudentModal").modal("hide");
                      $("#selectFileName").html("未选择文件...");
                      $("#studentFile").val("");
                      refresh(1, $("#studentPage").bs_pagination('getOption', 'rowsPerPage'));
                  } else {
                      layer.alert(data.message, {icon:5});
                  }
              }
          })
      });

      // 为“一键重置密码”按钮绑定单击事件
      $("#resetStudentPasswordBtn").click(function () {
        $.ajax({
          url:"student/resetStudentPassword.do",
          type:"post",
          dataType:"json",
          success:function (data){
            if (data.code == "200"){
              layer.alert(data.message, {icon:6});
              refresh($("#studentPage").bs_pagination('getOption', 'currentPage')
                      ,$("#studentPage").bs_pagination('getOption', 'rowsPerPage'));
            } else {
              layer.alert(data.message, {icon:5});
            }
          }
        })
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

    $.post("student/find.do", {
      "page": page,
      "pageSize": pageSize,
      "name" : $("#hidden_name").val(),
      "id_number" : $("#hidden_id_number").val(),
      "sex" : $("#hidden_sex").val(),
      "phone" : $("#hidden_phone").val(),
      "class_id" : $("#hidden_class_id").val()
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
        html += '<td><img src=".././images/shanchu.png"  alt="删除信息" onclick="deleteStudentById(\''+s.id+'\')"/></td>';
        html += '<td><img src=".././images/xiugai.png"  alt="修改信息" onclick="updateStudentById(\''+s.id+'\')"/></td>';
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

  function fileChange() {//注意：此处不能使用jQuery中的change事件，因为仅触发一次，因此使用标签的：onchange属性
    $.ajaxFileUpload({
      url: "student/ajaxImg.do", //用于文件上传的服务器端请求地址
      secureuri: false, //安全协议，一般设置为false
      fileElementId: "addAvatar",//文件上传控件的id属性  <input type="file" id="addAvatar" name="studentImage" />
      dataType: "json",
      success: function (data) {
        if (data.code == "200") {
          $("#imgDiv").empty();  //清空原有数据
          //创建一个图片的标签
          var imgObj = $("<img>");
          //给img标签对象追加属性
          imgObj.attr("src", ".././upload/" + data.retData);
          imgObj.attr("style", "width:150px;height:150px;border-radius:50%;");
          //将图片img标签追加到imgDiv末尾
          $("#imgDiv").append(imgObj);
          // 将图片的名称赋值给文本框
          $("#imgName").html(data.retData);
        } else {
          layer.alert(data.message, {icon: 7});
        }
      },
      error: function (e) {
        alert(e.message);
      }
    });
  }

  function fileChange2() {//注意：此处不能使用jQuery中的change事件，因为仅触发一次，因此使用标签的：onchange属性
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
          imgObj.attr("src", ".././upload/" + data.retData);
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

  function fileChange3() {//注意：此处不能使用jQuery中的change事件，因为仅触发一次，因此使用标签的：onchange属性
      // 收集参数
      var studentFileName = $("#studentFile").val();
      var type = studentFileName.substr(studentFileName.lastIndexOf(".")+1).toLowerCase(); // xls,XLS,Xls...
      if (type != "xls"){
          layer.alert("请选择xls文件类型的文件", {icon:7});
          return;
      }

      var studentFile = $("#studentFile")[0].files[0];
      if (studentFile.size > (5*1024*1024)){
          layer.alert("文件大小不能超过5MB", {icon:7});
          return;
      }

      alert(studentFile.name);
      $("#selectFileName").html(studentFile.name);

  }

  function changeDep() {
    var depName = $("#create_dep").val();
    $.ajax({
      url : "student/changeDep.do",
      data: {
        "dep_id" : depName
      },
      type : "post",
      dataType : "json",
      success : function (data) {
        $("#create_class_id").empty();
        var html = "";
        $.each(data, function (index, c) {
          html += '<option id="'+c.id+'">'+c.name+'</option>';
        })
        $("#create_class_id").append(html);
      }
    })
  }

  function changeUpdateDep() {
    var depName = $("#update_dep").val();
    $.ajax({
      url : "student/changeDep.do",
      data: {
        "dep_id" : depName
      },
      type : "post",
      dataType : "json",
      success : function (data) {
        $("#update_class_id").empty();
        var html = "";
        $.each(data, function (index, c) {
          html += '<option id="'+c.id+'">'+c.name+'</option>';
        })
        $("#update_class_id").append(html);
      }
    })
  }

  function deleteStudentById(studentId){
    if(confirm("您确定删除吗？")) {
      $.ajax({
        url : "student/deleteStudentById.do",
        data: {
          "id" : studentId
        },
        type : "post",
        dataType : "json",
        success : function (data) {
          if (data.code == "200"){
            layer.alert(data.message, {icon:6});
            /*
                删除成功后，回到第一页，维持每页展示对的记录数
             */
            refresh(1, $("#studentPage").bs_pagination('getOption', 'rowsPerPage'));
          }else {
            layer.alert(data.message, {icon:2});
          }

        }
      })
    }
  }

  // 为“更新”图片添加单击事件
  function updateStudentById(studentId) {
    $.ajax({
      url:"student/queryStudentById.do",
      data:{
        id:studentId
      },
      type:"post",
      dataType:"json",
      success:function (data){
        $("#hidden_id").val(data.retData.id);
        $("#update_name").val(data.retData.name);
        $("#update_email").val(data.retData.email);
        $("#update_phone").val(data.retData.phone);
        $("#update_sex").val(data.retData.sex);
        $("#update_lockState").val(data.retData.lockState);
        $("#update_isClock").val(data.retData.isClock);
        $("#update_password").val(data.retData.password);
        $("#update_class_id").val(data.retData.class_id);
        $("#update_dep").val(data.retData.dep_id);
        $("#updateImgName").html(data.retData.avatar);
        $("#update_address").val(data.retData.address);
        $("#updateImgDiv").empty();  //清空原有数据
        //创建一个图片的标签
        var imgObj = $("<img>");
        //给img标签对象追加属性
        imgObj.attr("src", ".././upload/" + data.retData.avatar);
        imgObj.attr("style", "width:150px;height:150px;border-radius:50%;");
        //将图片img标签追加到imgDiv末尾
        $("#updateImgDiv").append(imgObj);
        // 模拟用户改变select的onchange事件
        $("#update_dep").trigger("change");

      }
    })

    // 展现修改学生的模态窗口
    $("#editStudentModal").modal("show");
  }

  // 为“详情”按钮绑定单击事件
  function detailStudent(studentId){
    $.ajax({
      url:"student/queryStudentById.do",
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


  <!-- 创建学生信息的模态窗口 -->
  <div class="modal fade" id="createStudentModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 70%;">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" onclick="$('#createStudentModal').modal('hide');">
            <span aria-hidden="true">×</span>
          </button>
          <h4 class="modal-title" id="myModalLabelx">新建学生信息</h4>
        </div>
        <div class="modal-body">
          <form class="form-horizontal" role="form" id="createStudentForm">
            <div class="form-group">
              <label for="create_name" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="create_name">
              </div>

            </div>

            <div class="form-group">
               <label for="create_sex" class="col-sm-2 control-label">性别<span style="font-size: 15px; color: red;">*</span></label>
               <div class="col-sm-10" style="width: 150px;">
                 <select class="form-control" id="create_sex">
                   <option value="男">男</option>
                   <option value="女">女</option>
                 </select>
               </div>
            </div>

            <div class="form-group">
              <label for="create_address" class="col-sm-2 control-label">家庭地址</label>
              <div class="col-sm-10">
                <input type="text" class="form-control" id="create_address">
              </div>
            </div>

            <div class="form-group">
              <label for="create_dep" class="col-sm-2 control-label">系<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
               <select class="form-control" id="create_dep" onchange="changeDep()">
                 <c:forEach items="${requestScope.depList}" var="dep">
                   <option id="${dep.code}">${dep.short_name}</option>
                 </c:forEach>
               </select>
              </div>
            </div>
            <div class="form-group">
              <label for="create_class_id" class="col-sm-2 control-label">班级<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
                  <select class="form-control" id="create_class_id">
                    <c:forEach items="${requestScope.classList}" var="c">
                      <option id="${c.id}">${c.name}</option>
                    </c:forEach>
                  </select>
              </div>
            </div>
            <div class="form-group">
              <label for="create_phone" class="col-sm-2 control-label">手机号<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="create_phone">
              </div>
            </div>
            <div class="form-group" style="position: relative;">
              <label for="create_email" class="col-sm-2 control-label">邮箱<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="create_email">
              </div>
            </div>

            <div class="form-group" style="position: relative;">
              <label for="addAvatar" class="col-sm-2 control-label">头像<span style="font-size: 15px; color: red;"></span></label>
              <td style="margin-left: 8%">
                <br><div id="imgDiv" style="display:block; width: 40px; height: 50px;"></div>
                <br><br><br><br><br><br>
                <input type="file" id="addAvatar" name="studentImage" accept="image/jpg,image/png,image/jpeg,image/bmp" onchange="fileChange()">
                <span style="margin-left: 100px" id="imgName" >未选择文件...</span><br>
              </td>
            </div>
          </form>

        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
          <button type="button" class="btn btn-primary" id="saveStudentBtn">保存</button>
        </div>
      </div>
    </div>
  </div>

  <!-- 修改学生信息的模态窗口 -->
  <div class="modal fade" id="editStudentModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 70%;">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">
            <span aria-hidden="true">×</span>
          </button>
          <h4 class="modal-title" id="myModalLabel1">修改学生信息</h4>
        </div>
        <div class="modal-body">
          <form class="form-horizontal" role="form" id="studentUpdateForm">
            <div class="form-group">
              <label for="update_name" class="col-sm-2 control-label">姓名<span
                  style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="update_name">
              </div>

            </div>

            <div class="form-group">
              <label for="update_address" class="col-sm-2 control-label">家庭地址</label>
              <div class="col-sm-10">
                <input type="text" class="form-control" id="update_address">
              </div>
            </div>

            <div class="form-group">
              <label for="update_sex" class="col-sm-2 control-label">性别</label>
              <div class="col-sm-10" style="width: 150px;">
                <select class="form-control" id="update_sex">
                  <option value="男">男</option>
                  <option value="女">女</option>
                </select>
              </div>
              <label for="update_lockState" class="col-sm-2 control-label">账号状态</label>
              <div class="col-sm-10" style="width: 150px;">
                <select class="form-control" id="update_lockState">
                  <option value="1">1</option>
                  <option value="0">0</option>
                </select>
              </div>
              <label for="update_isClock" class="col-sm-2 control-label">是否打卡</label>
              <div class="col-sm-10" style="width: 150px;">
                <select class="form-control" id="update_isClock">
                  <option value="0">未打卡</option>
                  <option value="1">已打卡</option>
                </select>
              </div>
            </div>

            <div class="form-group">
              <label for="update_phone" class="col-sm-2 control-label">手机号<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="update_phone">
              </div>
            </div>
            <div class="form-group">
              <label for="update_password" class="col-sm-2 control-label">密码<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="update_password">
              </div>
            </div>
            <div class="form-group" style="position: relative;">
              <label for="update_email" class="col-sm-2 control-label">邮箱<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
                <input type="text" class="form-control" id="update_email">
              </div>
            </div>

            <div class="form-group">
              <label for="update_dep" class="col-sm-2 control-label">系<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 300px;">
                <select class="form-control" id="update_dep" onchange="changeUpdateDep()">
                  <c:forEach items="${requestScope.depList}" var="dep">
                    <option id="${dep.code}">${dep.short_name}</option>
                  </c:forEach>
                </select>
              </div>
              <label for="update_class_id" class="col-sm-2 control-label">班级<span style="font-size: 15px; color: red;">*</span></label>
              <div class="col-sm-10" style="width: 250px;">
                <select class="form-control" id="update_class_id">
                  <c:forEach items="${requestScope.allClassList}" var="c">
                    <option id="${c.id}">${c.name}</option>
                  </c:forEach>
                </select>
              </div>
            </div>

            <div class="form-group" style="position: relative;">
              <label for="updateImgDiv" class="col-sm-2 control-label">头像<span style="font-size: 15px; color: red;"></span></label>
              <td style="margin-left: 8%">
                <br><div id="updateImgDiv" style="display:block; width: 40px; height: 50px;"></div>
                <br><br><br><br><br><br>
                <input type="file" id="updateAvatar" name="studentImage" accept="image/jpg,image/png,image/jpeg,image/bmp" onchange="fileChange2()">
                <span style="margin-left: 100px" id="updateImgName">未选择文件...</span><br>
              </td>
            </div>


          </form>

        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
          <button type="button" class="btn btn-primary" id="saveUpdateStudentBtn">保存</button>
        </div>
      </div>
    </div>
  </div>


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
              <label for="detail_isClock" class="col-sm-2 control-label">是否打卡</label>
              <div class="col-sm-7" style="width: 150px;">
                <select class="form-control" id="detail_isClock" disabled>
                  <option value="0">未打卡</option>
                  <option value="1">已打卡</option>
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
                <input type="file" id="detailAvatar" name="studentImage" accept="image/jpg,image/png,image/jpeg,image/bmp" disabled>
                <span style="margin-left: 100px" id="detailImgName">未选择文件...</span><br>
              </td>
            </div>

            <div class="form-group">
                <div class="col-sm-10" style="width: 250px;">
                <td style="margin-left: 8%">
                    <br><div id="detailHealthImgDiv" style="display:block; width: 40px; height: 50px;"></div>
                    <br><br><br><br><br><br>
                    <input type="file" id="detailHealthAvatar" name="studentImage" accept="image/jpg,image/png,image/jpeg,image/bmp" disabled>
                    <span style="margin-left: 100px" id="detailHealthImgName">未选择文件...</span><br>
                </td>
                </div>
                <div class="col-sm-10" style="width: 250px;">
                <td style="margin-left: 8%">
                    <br><div id="detailTourImgDiv" style="display:block; width: 40px; height: 50px;"></div>
                    <br><br><br><br><br><br>
                    <input type="file" id="detailTourAvatar" name="studentImage" accept="image/jpg,image/png,image/jpeg,image/bmp" disabled>
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

    <!-- 导入学生的模态窗口 -->
    <div class="modal fade" id="importStudentModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" id="closeImportStudentBtn2">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入学生</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;" id="selectFile">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="studentFile" name="studentXlsFile" accept=".xls" onchange="fileChange3()">
                        <span style="margin-left: 100px"  id="selectFileName">未选择文件...</span><br>
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button id="closeImportStudentBtn" type="button" class="btn btn-default">关闭</button>
                    <button id="importStudentBtn" type="button" class="btn btn-primary">导入</button>
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
          <button type="button"  class="btn btn-primary" data-toggle="modal" data-target="#createStudentModal"><span
                  class="glyphicon glyphicon-plus"></span> 创建</button>
          <button type="button" class="btn btn-default" id="updateStudentBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
          <button type="button" class="btn btn-danger" id="deleteStudentBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
          <div class="btn-group" style="position: relative; top: 18%;">
            <button type="button" class="btn btn-default" data-toggle="modal" id="importStudentModalBtn" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
            <button id="exportStudentAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
            <button id="exportStudentCheckedBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
            <button id="resetStudentPasswordBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-refresh"></span> 一键重置密码 </button>
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
              <td colspan="2" align="center">操作</td>
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