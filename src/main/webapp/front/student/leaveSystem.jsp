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

        refresh(1, 2);

        // 为“查询”按钮添加单击事件
        $("#searchLeaveBtn").click(function () {
            refresh(1, 2);
        });

        // 为“请假”按钮添加单击事件
        $("#askLeaveBtn").click(function () {
            $("#createLeaveModal").modal("show");
        });

        // 为“请假保存”按钮绑定单击事件
        $("#saveLeaverBtn").click(function () {
            var reason = $.trim($("#reason").val());
            var startDate = $.trim($("#startDate").val());
            var endDate = $.trim($("#endDate").val());

            // 表单验证
            var DateTrue = /^\d{4}-\d{1,2}-\d{1,2}/;
            if (!DateTrue.test(startDate) || !DateTrue.test(endDate)){
                layer.alert("日期格式有误", {icon:7});
                return;
            }
            if (reason == ""){
                layer.alert("请假原因不能为空！", {icon:7});
                return;
            }


            $.ajax({
                url : "saveLeave.do",
                data : {
                    reason:reason,
                    startDate:startDate,
                    endDate:endDate,
                    studentName:"${sessionScope.sessionStudent.name}",
                    studentId:"${sessionScope.sessionStudent.id}"
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

            $("#createLeaveModal").modal("hide");
        })

    });

    // 定义一个函数，发送请求不同页码对应的数据
    function refresh(page, pageSize) {
        // 将查询文本框的信息存储到隐藏域中，方便进行查询操作
        $("#hidden_id").val($.trim($("#search_id").val()));
        $("#hidden_studentName").val($.trim($("#search_studentName").val()));
        $("#hidden_startDate").val($.trim($("#search_startDate").val()));
        $("#hidden_endDate").val($.trim($("#search_endDate").val()));
        $("#hidden_reason").val($.trim($("#search_reason").val()));

        $.post("getLeavesByConditionAndStudentId.do", {
            "page": page,
            "pageSize": pageSize,
            "startDate" : $.trim($("#hidden_startDate").val()),
            "endDate" : $.trim($("#hidden_endDate").val()),
            "reason" : $.trim($("#hidden_reason").val()),
            "studentId" : "${sessionScope.sessionStudent.id}"
        }, function (data) {
            // 清空leaveBody的数据
            $("#leaveBody").html("");
            var html = "";
            $.each(data.list, function(index, l) {
                html += '<tr>';
                html += '<td>'+l.reason+'</td>';
                html += '<td>'+l.startDate+'</td>';
                html += '<td>'+l.endDate+'</td>';
                if (l.isApproval == "0"){
                    html += '<td>未审批</td>';
                }else {
                    html += '<td>已审批</td>';
                }
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
        }, "json")
    }
</script>

<body style="width: 80%;">

<%--为查询文本框设置隐藏域--%>
<input type="hidden" id="hidden_startDate"/>
<input type="hidden" id="hidden_endDate"/>
<input type="hidden" id="hidden_reason"/>


<div class="modal fade" id="createLeaveModal" role="dialog" aria-hidden="true" data-backdrop="static" >
    <div class="modal-dialog" role="document" style="width: 70%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" onclick="$('#createLeaveModal').modal('hide');">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabelx">请假</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" id="leaveAddForm" role="form">
                    <div class="form-group">
                        <label for="reason" class="col-sm-2 control-label">请假原因<span style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="reason">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="startDate" class="col-sm-2 control-label">开始日期<span style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 250px">
                            <input type="text" class="form-control time" id="startDate">
                        </div>
                        <label for="endDate" class="col-sm-2 control-label">结束日期<span style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 250px;">
                            <input type="text" class="form-control time" id="endDate">
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveLeaverBtn">保存</button>
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
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 150px;">
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
                <button type="button" class="btn btn-primary" id="askLeaveBtn"><span class="glyphicon glyphicon-plus"></span> 请假</button>
            </div>
        </div>

        <div style="position: relative;top: 80px">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>请假原因</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                    <td>审批状态</td>
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