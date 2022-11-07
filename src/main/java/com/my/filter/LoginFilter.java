package com.my.filter;



import com.my.contants.Contants;
import com.my.entity.Admin;
import com.my.entity.Student;
import com.my.entity.Teacher;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("过滤器初始化");
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain)
            throws IOException, ServletException {
        // 1.得到HttpServletRequest
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        // 2.获取session
        HttpSession session = request.getSession();

        // 3，得到User对象
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);
        Teacher teacher = (Teacher) session.getAttribute(Contants.SESSION_TEACHER);
        Student student = (Student) session.getAttribute(Contants.SESSION_STUDENT);
        //Student student = (Student) session.getAttribute(Contants.SESSION_USER);

        // 4.得到请求路径
        String url = request.getRequestURI();
        // 5. 判断session是否存在user对象  如果存在,表示已登录;不存在,则未登录
        // indexOf 方法的作用   如果包含子字符串  则返回 子字符串的索引  如果不包含  则返回 -1
        if (("/epidemic/").equals(url) || "/epidemic/login.jsp".equals(url)){
            // 过滤器放行
            filterChain.doFilter(servletRequest, servletResponse);
        }
       // if (admin == null && teacher == null && student == null && url.indexOf("login.do") == -1) {
        if (admin == null && teacher == null && student == null && url.indexOf("login.do") == -1) {
            // 重定向到登录页面
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
        else {
            // 过滤器放行
            filterChain.doFilter(servletRequest, servletResponse);

        }
    }

    @Override
    public void destroy() {
        System.out.println("过滤器销毁");
    }
}
