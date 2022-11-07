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
</head>

<style>
    input[type="file"] {
        color: transparent;
        margin-left: 100px;
    }
</style>

<script type="text/javascript">
    $(function () {
        $(".time").datetimepicker({
            minView: "month", //语言
            language:  'zh-CN', //日期的格式
            format: 'yyyy-mm-dd', //可以选择的最小视图
            initialDate:new Date(),//初始化显示的日期
            autoclose: true, //设置选择完日期或者时间之后，日否自动关闭日历
            todayBtn: true, //设置是否显示"今天"按钮,默认是false
            clearBtn:true, //设置是否显示"清空"按钮，默认是false
            pickerPosition: "bottom-left"
        });

        //定制字段
        $("#definedColumns > li").click(function (e) {
            //防止下拉菜单消失
            e.stopPropagation();
        });

        // 为全选按钮触发事件
        $("#qx").click(function () {
            $("input[name=xz]").prop("checked", this.checked);
        })

        $("#leaveBody").on("click", $("input[name=xz]"), function () {
            $("#qx").prop("checked", $("input[name=xz]").length==$("input[name=xz]:checked").length);
        });

        refresh(1, 2);

        // 为“查询”按钮添加单击事件
        $("#searchLeaveBtn").click(function () {
            refresh(1, 2);
        });


        // 为“删除”按钮添加单击事件
        $("#deleteLeaveBtn").click(function () {
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
                        url : "leave/deleteLeaveByIds.do?ids="+param,
                        type : "post",
                        dataType : "json",
                        success : function (data) {
                            if (data.code == "200"){
                                layer.alert(data.message, {icon:6});
                                /*
                                    删除成功后，回到第一页，维持每页展示对的记录数
                                 */
                                refresh(1, $("#leavePage").bs_pagination('getOption', 'rowsPerPage'));
                            }else {
                                layer.alert(data.message, {icon:2});
                            }

                        }
                    })
                }
            }
        });


    });

    // 定义一个函数，发送请求不同页码对应的数据
    function refresh(page, pageSize) {
        $("#qx").prop("checked", false);

        // 将查询文本框的信息存储到隐藏域中，方便进行查询操作
        $("#hidden_id").val($.trim($("#search_id").val()));
        $("#hidden_studentName").val($.trim($("#search_studentName").val()));
        $("#hidden_startDate").val($.trim($("#search_startDate").val()));
        $("#hidden_endDate").val($.trim($("#search_endDate").val()));
        $("#hidden_reason").val($.trim($("#search_reason").val()));


        $.ajax({
            url: "queryLeaveByConditionAndClassId.do",
            data: {
                "page": page,
                "pageSize": pageSize,
                "studentName": $.trim($("#hidden_studentName").val()),
                "startDate": $.trim($("#hidden_startDate").val()),
                "endDate": $.trim($("#hidden_endDate").val()),
                "reason": $.trim($("#hidden_reason").val()),
                "ci" : "${sessionScope.sessionTeacher.class_id}"
            },
            type: "post",
            dataType: "json",
            success: function (data) {
                // 清空leaveBody的数据
                $("#leaveBody").html("");
                var html = "";
                $.each(data.list, function (index, l) {
                    html += '<tr>';
                    html += '<td><input name="xz" type="checkbox" value="' + l.id + '"/></td>';
                    html += '<td style="color: #0078ff" onclick="detailStudent(\'' + l.studentId + '\')">' + l.studentName + '</td>';
                    html += '<td>' + l.reason + '</td>';
                    html += '<td>' + l.startDate + '</td>';
                    html += '<td>' + l.endDate + '</td>';
                    if (l.isApproval == "0") {
                        html += '<td style="color: #0078ff" onclick="approval(\'' + l.id + '\')">审批</td>';
                    } else {
                        html += '<td>已审批</td>';
                    }
                    html += '<td><img src=".././images/shanchu.png"  alt="删除信息" onclick="deleteLeaveById(\'' + l.id + '\')"/></td>';
                    html += '</tr>';
                })
                $("#leaveBody").append(html);

                //bootstrap的分页插件
                $("#leavePage").bs_pagination({
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
            }
        })

        /*$.post("queryLeaveByConditionAndClassId.do", {
            "page": page,
            "pageSize": pageSize,
            "studentName" : $.trim($("#hidden_studentName").val()),
            "startDate" : $.trim($("#hidden_startDate").val()),
            "endDate" : $.trim($("#hidden_endDate").val()),
            "reason" : $.trim($("#hidden_reason").val()),
            "ci" : "${sessionScope.sessionTeacher.class_id}"
        }, function (data) {
            // 清空leaveBody的数据
            $("#leaveBody").html("");
            var html = "";
            $.each(data.list, function(index, l) {
                html += '<tr>';
                html += '<td><input name="xz" type="checkbox" value="'+l.id+'"/></td>';
                html += '<td style="color: #0078ff" onclick="detailStudent(\''+l.studentId+'\')">'+l.studentName+'</td>';
                html += '<td>'+l.reason+'</td>';
                html += '<td>'+l.startDate+'</td>';
                html += '<td>'+l.endDate+'</td>';
                if (l.isApproval == "0"){
                    html += '<td style="color: #0078ff" onclick="approval(\''+l.id+'\')">审批</td>';
                }else {
                    html += '<td>已审批</td>';
                }
                html += '<td><img src=".././images/shanchu.png"  alt="删除信息" onclick="deleteLeaveById(\''+l.id+'\')"/></td>';
                html += '</tr>';
            })
            $("#leaveBody").append(html);

            //bootstrap的分页插件
            $("#leavePage").bs_pagination({
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
        }, "json")*/
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
                $("#detail_email").val(data.retData.email);
                $("#detail_phone").val(data.retData.phone);
                $("#detail_sex").val(data.retData.sex);
                // $("#detail_password").val(data.retData.password);
                $("#detail_dep_id").val(data.retData.dep_id);
                $("#detail_class_id").val(data.retData.class_id);
                // $("#detail_lockState").val(data.retData.lockState);
                $("#detail_isClock").val(data.retData.isClock);
                $("#detailImgName").html(data.retData.avatar);
                $("#detailHealthImgName").html(data.retData.healthCode);
                $("#detailTourImgName").html(data.retData.tourCode);
                $("#detail_address").val(data.retData.address);
                $("#detailImgDiv").empty();  //清空原有数据
                //创建一个图片的标签
                var imgObj = $("<img>");
                //给img标签对象追加属性
                imgObj.attr("src", "../image_student/" + data.retData.avatar);
                imgObj.attr("style", "width:150px;height:150px;border-radius:50%;");
                //将图片img标签追加到imgDiv末尾
                $("#detailImgDiv").append(imgObj);

                $("#detailHealthImgDiv").empty();  //清空原有数据
                //创建一个图片的标签
                var imgObj = $("<img>");
                //给img标签对象追加属性
                imgObj.attr("src", "../image_student/" + data.retData.healthCode);
                imgObj.attr("style", "width:150px;height:200;");
                //将图片img标签追加到imgDiv末尾
                $("#detailHealthImgDiv").append(imgObj);

                $("#detailTourImgDiv").empty();  //清空原有数据
                //创建一个图片的标签
                var imgObj = $("<img>");
                //给img标签对象追加属性
                imgObj.attr("src", "../image_student/" + data.retData.tourCode);
                imgObj.attr("style", "width:150px;height:200;");
                //将图片img标签追加到imgDiv末尾
                $("#detailTourImgDiv").append(imgObj);

            }
        })

        // 展现学生的模态窗口
        $("#detailStudentModal").modal("show");
    }

    // 单个删除
    function deleteLeaveById(id){
        if(confirm("您确定删除吗？")) {
            $.ajax({
                url : "leave/deleteLeaveById.do",
                data: {
                    "id" : id
                },
                type : "post",
                dataType : "json",
                success : function (data) {
                    if (data.code == "200"){
                        layer.alert(data.message, {icon:6});
                        /*
                            删除成功后，回到第一页，维持每页展示对的记录数
                         */
                        refresh(1, $("#leavePage").bs_pagination('getOption', 'rowsPerPage'));
                    }else {
                        layer.alert(data.message, {icon:2});
                    }

                }
            })
        }
    }

    // 审批
    function approval(id){
        $.ajax({
            url : "leave/approval.do",
            data: {
                "id" : id
            },
            type : "post",
            dataType : "json",
            success : function (data) {
                if (data.code == "200"){
                    layer.alert(data.message, {icon:6});

                    refresh(1, $("#leavePage").bs_pagination('getOption', 'rowsPerPage'));
                }else {
                    layer.alert(data.message, {icon:2});
                }

            }
        })
    }

</script>

<body style="width: 80%;">

<%--为更新文本框设置隐藏域--%>
<input type="hidden" id="hidden_id"/>
<%--为查询文本框设置隐藏域--%>
<input type="hidden" id="hidden_studentName"/>
<input type="hidden" id="hidden_startDate"/>
<input type="hidden" id="hidden_endDate"/>
<input type="hidden" id="hidden_reason"/>

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
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="detail_name" readonly>
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
                        <div class="col-sm-10" style="width: 200px;">
                            <select class="form-control" id="detail_sex" disabled>
                                <option value="男">男</option>
                                <option value="女">女</option>
                            </select>
                        </div>
                        <label for="detail_isClock" class="col-sm-1 control-label">是否打卡</label>
                        <div class="col-sm-10" style="width: 200px;">
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
                        <label for="detailImgDiv" class="col-sm-2 control-label">图片介绍<span style="font-size: 15px; color: red;"></span></label>
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
            <h3>请假列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
                <div class="form-group">
                    <div class="input-group" style="width:210px">
                        <div class="input-group-addon">姓名</div>
                        <input id="search_studentName" class="form-control" type="text">
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group" style="width:210px">
                        <div class="input-group-addon">请假原因</div>
                        <input id="search_reason" class="form-control" type="text">
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group" style="width: 210px;">
                        <div class="input-group-addon">开始日期</div>
                        <input id="search_startDate" class="form-control time" type="text">
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group" style="width:210px">
                        <div class="input-group-addon">结束日期</div>
                        <input id="search_endDate" class="form-control time" type="text">
                    </div>
                </div>
                <br>
                <button id="searchLeaveBtn" type="button" class="btn btn-primary" style="position: relative; top:25px;left:45%;width:100px;">查询</button>
            </form>
        </div>

        <div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 60px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-danger" id="deleteLeaveBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>
        </div>

        <div style="position: relative;top: 80px">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input id="qx" type="checkbox" /></td>
                    <td>姓名</td>
                    <td>请假原因</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                    <td>审批状态</td>
                    <td>操作</td>
                </tr>
                </thead>
                <tbody id="leaveBody">

                </tbody>
            </table>

            <footer class="message_footer">
                <nav>
                    <%--分页插件--%>
                    <div  style="height: 50px; position: relative;top: 30px;">
                        <div id="leavePage"></div>
                    </div>
                </nav>
            </footer>
        </div>
    </div>

</div>
</body>

</html>