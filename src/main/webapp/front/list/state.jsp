<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String base = request.getContextPath() + "/";
String url = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + base;
%>

<head>
  <base href="<%=url%>">
  <link rel="stylesheet" href="./jquery/bootstrap_3.3.0/css/bootstrap.min.css">
  <script type="text/javascript" src="./jquery/jquery-1.11.1-min.js"></script>
  <script type="text/javascript" src="./jquery/bootstrap.js"></script>
  <script type="text/javascript" src="./jquery/layer-3.5.1/layer.js"></script>
</head>

<script type="text/javascript">
  window.location.href="https://voice.baidu.com/act/newpneumonia/newpneumonia/?from=osari_pc_3#tab1";
</script>
<body>

</body>
</html>