package com.my.controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.my.contants.Contants;
import com.my.entity.*;
import com.my.entity.Class;
import com.my.service.*;
import com.my.utils.DateUtils;
import com.my.utils.FileNameUtil;
import com.my.utils.HSSFUtils;
import com.my.utils.MD5Util;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Controller
@RequestMapping(value = "/admin")
public class AdminController {

    @Resource
    private AdminService adminService;
    @Resource
    private TeacherService teacherService;
    @Resource
    private StudentService studentService;
    @Resource
    private LeaveService leaveService;
    @Resource
    private ClassService classService;
    @Resource
    private DicDepService dicDepService;

    private String saveFileName = "";

    /**
     * 文件上传的类型
     */
    public static final List<String> AVATAR_TYPES = new ArrayList<>();
    static {
        AVATAR_TYPES.add("image/png");
        AVATAR_TYPES.add("image/jpg");
        AVATAR_TYPES.add("image/bmp");
        AVATAR_TYPES.add("image/jpeg");
    }

    // 登录验证
    @ResponseBody
    @RequestMapping(value = "/login.do")
    public ReturnObject login(HttpServletResponse response, HttpSession session,
                              String userName, String password, String isRemPwd, String identity){

        // 添加线程休眠，根据客户需求可以优化
        /*try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }*/
        ReturnObject returnObject = new ReturnObject();
        if ("admin".equals(identity)){
            Admin admin = adminService.login(userName, MD5Util.getMD5(password));

            if(admin != null) {
                admin.setPassword(password);
                session.setAttribute(Contants.SESSION_USER, admin);
                returnObject.setCode(Contants.RETURN_OBJECT_SUCCESS);
            }
            else {
                returnObject.setCode(Contants.RETURN_OBJECT_FAIL);
                returnObject.setMessage("用户名或密码错误");
                return returnObject;
            }

            // 判断是否需要自动登录
            if ("true".equals(isRemPwd)){
                Cookie cookie = new Cookie("adminName", userName);
                // 设置session存活时间
//            cookie.setMaxAge(3*60);
                cookie.setMaxAge(10*24*60*60);
                cookie.setHttpOnly(false);
                cookie.setPath("/");
                response.addCookie(cookie);

                Cookie cookie1 = new Cookie("password1", password);
//            cookie1.setMaxAge(3*60);
                cookie1.setMaxAge(10*24*60*60);
                cookie1.setHttpOnly(false);
                cookie1.setPath("/");
                response.addCookie(cookie1);
                Cookie cookie2 = new Cookie("select", identity);
                cookie2.setMaxAge(10*24*60*60);
                cookie2.setHttpOnly(false);
                cookie2.setPath("/");
                response.addCookie(cookie2);

            } else {
                // 把没有过期的cookie删除
                Cookie cookie = new Cookie("adminName", "0");
                cookie.setMaxAge(0);
                cookie.setHttpOnly(false);
                cookie.setPath("/");
                response.addCookie(cookie);
                Cookie cookie1 = new Cookie("password1", "0");
                cookie1.setMaxAge(0);
                cookie1.setHttpOnly(false);
                cookie1.setPath("/");
                response.addCookie(cookie1);
                Cookie cookie2 = new Cookie("select", "0");
                cookie2.setMaxAge(0);
                cookie2.setHttpOnly(false);
                cookie2.setPath("/");
                response.addCookie(cookie2);
            }
        } else if ("teacher".equals(identity)){
            Teacher teacher = teacherService.login(userName, password);
            if(teacher != null) {
                if ("0".equals(teacher.getLockState())){
                    returnObject.setCode(Contants.RETURN_OBJECT_FAIL);
                    returnObject.setMessage("账号被锁定，请联系管理员....");
                    return returnObject;
                }
                //teacher.setPassword(password);
                Class c = classService.queryClassById(teacher.getClass_id());
                session.setAttribute("className", c.getName());
                session.setAttribute(Contants.SESSION_TEACHER, teacher);
                returnObject.setCode(Contants.RETURN_OBJECT_SUCCESS);
            }
            else {
                returnObject.setCode(Contants.RETURN_OBJECT_FAIL);
                returnObject.setMessage("用户名或密码错误");
            }

            // 判断是否需要自动登录
            if ("true".equals(isRemPwd)){
                Cookie cookie = new Cookie("adminName", userName);
                // 设置session存活时间
//            cookie.setMaxAge(3*60);
                cookie.setMaxAge(10*24*60*60);
                cookie.setHttpOnly(false);
                cookie.setPath("/");
                response.addCookie(cookie);

                Cookie cookie1 = new Cookie("password1", password);
//            cookie1.setMaxAge(3*60);
                cookie1.setMaxAge(10*24*60*60);
                cookie1.setHttpOnly(false);
                cookie1.setPath("/");
                response.addCookie(cookie1);
                Cookie cookie2 = new Cookie("select", identity);
                cookie2.setMaxAge(10*24*60*60);
                cookie2.setHttpOnly(false);
                cookie2.setPath("/");
                response.addCookie(cookie2);

            } else {
                // 把没有过期的cookie删除
                Cookie cookie = new Cookie("adminName", "0");
                cookie.setMaxAge(0);
                cookie.setHttpOnly(false);
                cookie.setPath("/");
                response.addCookie(cookie);
                Cookie cookie1 = new Cookie("password1", "0");
                cookie1.setMaxAge(0);
                cookie1.setHttpOnly(false);
                cookie1.setPath("/");
                response.addCookie(cookie1);
                Cookie cookie2 = new Cookie("select", "0");
                cookie2.setMaxAge(0);
                cookie2.setHttpOnly(false);
                cookie2.setPath("/");
                response.addCookie(cookie2);
            }
        } else if ("student".equals(identity)){
            Student student = studentService.login(userName, password);
            if(student != null) {
                if ("0".equals(student.getLockState())){
                    returnObject.setCode(Contants.RETURN_OBJECT_FAIL);
                    returnObject.setMessage("账号被锁定，请联系管理员....");
                    return returnObject;
                }
                session.setAttribute(Contants.SESSION_STUDENT, student);
                returnObject.setCode(Contants.RETURN_OBJECT_SUCCESS);
            }
            else {
                returnObject.setCode(Contants.RETURN_OBJECT_FAIL);
                returnObject.setMessage("用户名或密码错误");
            }

            // 判断是否需要自动登录
            if ("true".equals(isRemPwd)){
                Cookie cookie = new Cookie("adminName", userName);
                // 设置session存活时间
//            cookie.setMaxAge(3*60);
                cookie.setMaxAge(10*24*60*60);
                cookie.setHttpOnly(false);
                cookie.setPath("/");
                response.addCookie(cookie);

                Cookie cookie1 = new Cookie("password1", password);
//            cookie1.setMaxAge(3*60);
                cookie1.setMaxAge(10*24*60*60);
                cookie1.setHttpOnly(false);
                cookie1.setPath("/");
                response.addCookie(cookie1);
                Cookie cookie2 = new Cookie("select", identity);
                cookie2.setMaxAge(10*24*60*60);
                cookie2.setHttpOnly(false);
                cookie2.setPath("/");
                response.addCookie(cookie2);

            } else {
                // 把没有过期的cookie删除
                Cookie cookie = new Cookie("adminName", "0");
                cookie.setMaxAge(0);
                cookie.setHttpOnly(false);
                cookie.setPath("/");
                response.addCookie(cookie);
                Cookie cookie1 = new Cookie("password1", "0");
                cookie1.setMaxAge(0);
                cookie1.setHttpOnly(false);
                cookie1.setPath("/");
                response.addCookie(cookie1);
                Cookie cookie2 = new Cookie("select", "0");
                cookie2.setMaxAge(0);
                cookie2.setHttpOnly(false);
                cookie2.setPath("/");
                response.addCookie(cookie2);
            }
        }

        return returnObject;

    }

    @RequestMapping(value = "/toMain.do")
    public String toMain(){
        return "admin/toMain";
    }

    @RequestMapping(value = "/toState.do")
    public String toState(){
        return "list/state";
    }

    @RequestMapping(value = "/toTeacher.do")
    public String toTeacher(){
        return "admin/information/teacher";
    }

    @RequestMapping(value = "/toHealthPunch.do")
    public String toHealthPunch(){
        return "admin/information/healthPunch";
    }

    @RequestMapping(value = "/toLeave.do")
    public String toLeave(){
        return "admin/information/leaveSystem";
    }

    // 安全退出
    @RequestMapping(value = "/logout.do")
    public String Logout(HttpServletResponse response, HttpSession session){
        // 清除cookie
        Cookie cookie = new Cookie("adminName", "0");
        cookie.setMaxAge(0);
        cookie.setHttpOnly(false);
        cookie.setPath("/");
        response.addCookie(cookie);
        Cookie cookie1 = new Cookie("password1", "0");
        cookie1.setMaxAge(0);
        cookie1.setHttpOnly(false);
        cookie1.setPath("/");
        response.addCookie(cookie1);
        Cookie cookie2 = new Cookie("select", "0");
        cookie2.setMaxAge(0);
        cookie2.setHttpOnly(false);
        cookie2.setPath("/");
        response.addCookie(cookie2);
        // 销毁session,释放内存
        session.invalidate();
        // 重定向到首页，不把数据传过去
        return "redirect:/login.jsp";
    }

    // 更新密码
    @ResponseBody
    @RequestMapping(value = "/updatePwd.do")
    public Object updatePwd(Admin admin, HttpSession session, HttpServletResponse response){
        admin.setPassword(MD5Util.getMD5(admin.getPassword()));
        boolean flag = adminService.setPwd(admin);
        ReturnObject returnObject = new ReturnObject();
        if (flag == true){
            Cookie cookie = new Cookie("password1", "0");
            cookie.setMaxAge(0);
            cookie.setHttpOnly(false);
            cookie.setPath("/");
            response.addCookie(cookie);

            // 销毁session,释放内存
            session.invalidate();

            returnObject.setCode("200");
        } else {
            returnObject.setCode("304");
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    // 根据条件查找教师
    @ResponseBody
    @RequestMapping(value = "/teacher/find.do")
    public PageInfo<Teacher> find(Integer page, Integer pageSize, Teacher teacher) {
        PageHelper.startPage(page, pageSize);
        List<Teacher> teacherList = adminService.getTeachers(teacher);
        PageInfo<Teacher> pageInfo = new PageInfo<>(teacherList);
        return pageInfo;
    }

    // 异步ajax文件上传处理（教师头像）
    @ResponseBody
    @RequestMapping(value = "/teacher/ajaxImg.do")
    public Object ajaxImg(HttpServletRequest request, MultipartFile teacherImage) {
        saveFileName = FileNameUtil.getUUIDFileName()+FileNameUtil.getFileType(teacherImage.getOriginalFilename());

        if (!AVATAR_TYPES.contains(teacherImage.getContentType())){
            JSONObject object = new JSONObject();
            object.put("code", "303");
            object.put("message", "Allowed file types:" + AVATAR_TYPES);
            return object.toString();
        }

        // 得到项目中图片存储的路径
        String path = request.getServletContext().getRealPath("/upload");
        // 转存
        try {
            teacherImage.transferTo(new File(path + File.separator + saveFileName));
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 返回给客户端JSON对象，封装图片的路径，为了在页面实现立即回显
        JSONObject object = new JSONObject();
        object.put("retData", saveFileName);
        object.put("code", "200");

        return object.toString();
    }

    // 根据班级名称查询班级
    @ResponseBody
    @RequestMapping("/teacher/queryClassByName.do")
    public Object queryCustomerNameByName(){
        List<String> nameList = classService.queryClassByName();
        return nameList;
    }


    // 新增教师
    @ResponseBody
    @RequestMapping(value = "/teacher/saveTeacher.do")
    public Object saveTeacher(Teacher teacher, HttpSession session) {
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);
        teacher.setCreateBy(admin.getName());
        ReturnObject returnObject = adminService.saveCreateTeacher(teacher);
        return returnObject;
    }

    // 单个删除教师
    @ResponseBody
    @RequestMapping(value = "/teacher/deleteTeacherById.do")
    public Object deleteTeacherById(String id){
        boolean flag = teacherService.deleteTeacherById(id);
        ReturnObject returnObject = new ReturnObject();
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("删除教师成功");
        }else {
            returnObject.setCode("306");
            returnObject.setMessage("系统忙，请销后再试...");
        }
        return returnObject;
    }

    // 删除多个教师
    @ResponseBody
    @RequestMapping(value = "/teacher/deleteTeacherByIds.do")
    public Object deleteTeacherByIds(String ids){
        // 将字符串以','分割保存到数组中
        String[] d = ids.split(",");
        boolean flag = adminService.deleteTeacherByIds(d);
        ReturnObject returnObject = new ReturnObject();
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("删除教师成功");
        }else {
            returnObject.setCode("307");
            returnObject.setMessage("系统忙，请销后再试...");
        }
        return returnObject;
    }

    // 根据id查询教师信息
    @ResponseBody
    @RequestMapping(value = "/teacher/queryTeacherById.do")
    public Object queryTeacherById(String id){
        ReturnObject returnObject = new ReturnObject();
        Teacher teacher = teacherService.queryTeacherById(id);
        returnObject.setRetData(teacher);
        return returnObject;
    }

    // 更新教师
    @ResponseBody
    @RequestMapping(value = "/teacher/updateTeacher.do")
    public Object updateTeacher(Teacher teacher, HttpSession session) {
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);

        teacher.setEditBy(admin.getName());
        ReturnObject returnObject = adminService.updateTeacher(teacher);
        return returnObject;
    }

    // 导出所有教师
    @RequestMapping("/teacher/exportAllTeachers.do")
    public void exportAllTeachers(HttpServletResponse response) throws IOException {
        // 调用service层方法，查询勾选的市场活动
        List<Teacher> teacherList = adminService.getAllTeachers();
        // 创建excel文件，并且把teacherList写入到excel文件中
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("教师信息列表");
        HSSFRow row = sheet.createRow(0);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("教职工号");
        cell = row.createCell(1);
        cell.setCellValue("姓名");
        cell = row.createCell(2);
        cell.setCellValue("密码");
        cell = row.createCell(3);
        cell.setCellValue("性别");
        cell = row.createCell(4);
        cell.setCellValue("邮箱");
        cell = row.createCell(5);
        cell.setCellValue("手机号");
        cell = row.createCell(6);
        cell.setCellValue("所管理班级");
        cell = row.createCell(7);
        cell.setCellValue("地址");

        if (teacherList != null && teacherList.size() > 0){
            Teacher teacher = null;
            // 遍历activityList，创建HSSFRow对象，生成所有数据行
            for (int i = 0; i < teacherList.size(); i++){
                teacher = teacherList.get(i);
                // 每遍历一个activity，生成一行
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(teacher.getTeacherId());
                cell = row.createCell(1);
                cell.setCellValue(teacher.getName());
                cell = row.createCell(2);
                cell.setCellValue(teacher.getPassword());
                cell = row.createCell(3);
                cell.setCellValue(teacher.getSex());
                cell = row.createCell(4);
                cell.setCellValue(teacher.getEmail());
                cell = row.createCell(5);
                cell.setCellValue(teacher.getPhone());
                cell = row.createCell(6);
                cell.setCellValue(teacher.getClass_id());
                cell = row.createCell(7);
                cell.setCellValue(teacher.getAddress());
            }
        }

        // 把生成的excel文件下载到客户端
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=teacherList.xls");
        OutputStream out = response.getOutputStream();

        wb.write(out);

        wb.close();
        out.flush();
    }

    // 导出所选教师
    @RequestMapping("/teacher/exportCheckedTeachers.do")
    public void exportCheckedUsers(HttpServletResponse response, String[] id) throws IOException {
        // 调用service层方法，查询勾选的市场活动
        List<Teacher> teacherList = adminService.getTeachersByIds(id);
        // 创建excel文件，并且把activityList写入到excel文件中
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("教师信息列表");
        HSSFRow row = sheet.createRow(0);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("教职工号");
        cell = row.createCell(1);
        cell.setCellValue("姓名");
        cell = row.createCell(2);
        cell.setCellValue("密码");
        cell = row.createCell(3);
        cell.setCellValue("性别");
        cell = row.createCell(4);
        cell.setCellValue("邮箱");
        cell = row.createCell(5);
        cell.setCellValue("手机号");
        cell = row.createCell(6);
        cell.setCellValue("所管理班级");
        cell = row.createCell(7);
        cell.setCellValue("地址");

        if (teacherList != null && teacherList.size() > 0){
            Teacher teacher = null;
            // 遍历activityList，创建HSSFRow对象，生成所有数据行
            for (int i = 0; i < teacherList.size(); i++){
                teacher = teacherList.get(i);
                // 每遍历一个activity，生成一行
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(teacher.getTeacherId());
                cell = row.createCell(1);
                cell.setCellValue(teacher.getName());
                cell = row.createCell(2);
                cell.setCellValue(teacher.getPassword());
                cell = row.createCell(3);
                cell.setCellValue(teacher.getSex());
                cell = row.createCell(4);
                cell.setCellValue(teacher.getEmail());
                cell = row.createCell(5);
                cell.setCellValue(teacher.getPhone());
                cell = row.createCell(6);
                cell.setCellValue(teacher.getClass_id());
                cell = row.createCell(7);
                cell.setCellValue(teacher.getAddress());
            }
        }

        // 把生成的excel文件下载到客户端
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=teacherList.xls");
        OutputStream out = response.getOutputStream();

        wb.write(out);

        wb.close();
        out.flush();
    }

    // 导入教师
    @ResponseBody
    @RequestMapping("/teacher/importTeachers.do")
    public Object importTeachers(MultipartFile teacherFile, HttpSession session){
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();

        try {
            InputStream is = teacherFile.getInputStream();
            HSSFWorkbook wb = new HSSFWorkbook(is);
            HSSFSheet sheet = wb.getSheetAt(0); // 页的下标，下标从0开始，依次递增
            // 根据sheet获取HSSFRow对象，封装了一行所有的信息
            HSSFRow row = null;
            HSSFCell cell = null;
            Teacher teacher = null;
            List<Teacher> teacherList = new ArrayList<>();
            for (int i = 1; i <= sheet.getLastRowNum(); i++){
                row = sheet.getRow(i);  // 行的下标，下标从0开始，依次增加
                teacher = new Teacher();
                for (int j = 0; j < row.getLastCellNum(); j++){
                    cell = row.getCell(j); // 列的下标，下标从0开始，依次增加
                    // 获取列中的数据
                    String cellValue = HSSFUtils.getCellValueForStr(cell);
                    if (j == 1){
                        teacher.setName(cellValue);
                    } else if (j == 2){
                        teacher.setPassword(cellValue);
                    } else if (j == 3){
                        teacher.setSex(cellValue);
                    } else if (j == 4){
                        teacher.setEmail(cellValue);
                    } else if (j == 5){
                        teacher.setPhone(cellValue);
                    } else if (j == 6){
                        teacher.setClass_id(cellValue);
                    } else if (j == 7){
                        teacher.setAddress(cellValue);
                    }
                }
                teacher.setCreateBy(admin.getName());
                // 每一行中所有列封装完之后，把activity保存到list中
                teacherList.add(teacher);
            }

            // 调用service层方法，保存市场活动
            returnObject = adminService.saveTeachers(teacherList);

        } catch (Exception e){
            returnObject.setCode("310");
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }


    // 跳转到学生页面
    @RequestMapping(value = "/toStudent.do")
    public String toStudent(HttpServletRequest request){
        List<DicDep> depList = dicDepService.getAllDicDep();
        List<Class> classList = classService.queryClassByDepCode("00");
        List<Class> allClassList = classService.queryAllClass();
        // 将数据存储到request作用域中
        request.setAttribute("depList", depList);
        request.setAttribute("classList", classList);
        request.setAttribute("allClassList", allClassList);
        return "admin/information/student";
    }

    // 根据条件查找学生
    @ResponseBody
    @RequestMapping(value = "/student/find.do")
    public PageInfo<Student> find(Integer page, Integer pageSize, Student student) {
        PageHelper.startPage(page, pageSize);
        List<Student> studentList = studentService.getStudents(student);
        PageInfo<Student> pageInfo = new PageInfo<>(studentList);
        return pageInfo;
    }

    // 新增学生
    @ResponseBody
    @RequestMapping(value = "/student/saveStudent.do")
    public Object saveStudent(Student student, HttpSession session) {
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);

        student.setCreateBy(admin.getName());
        ReturnObject returnObject = studentService.saveStudent(student);
        return returnObject;
    }

    // 系改变
    @ResponseBody
    @RequestMapping(value = "/student/changeDep.do")
    public List<Class> changeDep(String dep_id, HttpServletRequest request){

        DicDep dicDep = dicDepService.getDicDepByShortName(dep_id);
        List<Class> classList = classService.queryClassByDepCode(dicDep.getCode());
        return classList;
    }


    // 异步ajax文件上传处理(学生头像)
    @ResponseBody
    @RequestMapping(value = "/student/ajaxImg.do")
    public Object ajaxStudentImg(HttpServletRequest request, MultipartFile studentImage) {
        saveFileName = FileNameUtil.getUUIDFileName()+FileNameUtil.getFileType(studentImage.getOriginalFilename());

        if (!AVATAR_TYPES.contains(studentImage.getContentType())){
            JSONObject object = new JSONObject();
            object.put("code", "312");
            object.put("message", "Allowed file types:" + AVATAR_TYPES);
            return object.toString();
        }

        // 得到项目中图片存储的路径
        String path = request.getServletContext().getRealPath("/upload");
        // 转存
        try {
            studentImage.transferTo(new File(path + File.separator + saveFileName));
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 返回给客户端JSON对象，封装图片的路径，为了在页面实现立即回显
        JSONObject object = new JSONObject();
        object.put("retData", saveFileName);
        object.put("code", "200");

        return object.toString();
    }

    // 根据id查询学生信息
    @ResponseBody
    @RequestMapping(value = "/student/queryStudentById.do")
    public Object queryStudentById(String id){
        ReturnObject returnObject = new ReturnObject();
        Student student = studentService.queryStudentById(id);
        returnObject.setRetData(student);
        return returnObject;
    }

    // 单个删除学生
    @ResponseBody
    @RequestMapping(value = "/student/deleteStudentById.do")
    public Object deleteStudentById(String id){
        boolean flag = studentService.deleteStudentById(id);
        ReturnObject returnObject = new ReturnObject();
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("删除学生成功");
        }else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后再试...");
        }
        return returnObject;
    }

    // 删除多个学生
    @ResponseBody
    @RequestMapping(value = "/student/deleteStudentByIds.do")
    public Object deleteStudentByIds(String ids){
        // 将字符串以','分割保存到数组中
        String[] d = ids.split(",");
        boolean flag = studentService.deleteStudentByIds(d);
        ReturnObject returnObject = new ReturnObject();
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("删除学生成功");
        }else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后再试...");
        }
        return returnObject;
    }

    // 更新学生
    @ResponseBody
    @RequestMapping(value = "/student/updateStudent.do")
    public Object updateTeacher(Student student, HttpSession session) {
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);

        student.setEditBy(admin.getName());
        student.setEditTime(DateUtils.formateDateTime(new Date()));
        ReturnObject returnObject = studentService.updateStudent(student);
        return returnObject;
    }

    // 导出所有学生
    @RequestMapping("/student/exportAllStudents.do")
    public void exportAllStudents(HttpServletResponse response) throws IOException {
        // 调用service层方法，查询勾选的市场活动
        List<Student> studentList = studentService.queryAllStudents();
        // 创建excel文件，并且把studentList写入到excel文件中
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("学生信息列表");
        HSSFRow row = sheet.createRow(0);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("学号");
        cell = row.createCell(1);
        cell.setCellValue("姓名");
        cell = row.createCell(2);
        cell.setCellValue("密码");
        cell = row.createCell(3);
        cell.setCellValue("性别");
        cell = row.createCell(4);
        cell.setCellValue("邮箱");
        cell = row.createCell(5);
        cell.setCellValue("手机号");
        cell = row.createCell(6);
        cell.setCellValue("系部");
        cell = row.createCell(7);
        cell.setCellValue("班级");
        cell = row.createCell(8);
        cell.setCellValue("地址");

        if (studentList != null && studentList.size() > 0){
            Student student = null;
            // 遍历activityList，创建HSSFRow对象，生成所有数据行
            for (int i = 0; i < studentList.size(); i++){
                student = studentList.get(i);
                // 每遍历一个activity，生成一行
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(student.getId_number());
                cell = row.createCell(1);
                cell.setCellValue(student.getName());
                cell = row.createCell(2);
                cell.setCellValue(student.getPassword());
                cell = row.createCell(3);
                cell.setCellValue(student.getSex());
                cell = row.createCell(4);
                cell.setCellValue(student.getEmail());
                cell = row.createCell(5);
                cell.setCellValue(student.getPhone());
                cell = row.createCell(6);
                cell.setCellValue(student.getDep_id());
                cell = row.createCell(7);
                cell.setCellValue(student.getClass_id());
                cell = row.createCell(8);
                cell.setCellValue(student.getAddress());
            }
        }

        // 把生成的excel文件下载到客户端
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=studentList.xls");
        OutputStream out = response.getOutputStream();

        wb.write(out);

        wb.close();
        out.flush();
    }

    // 导出所选学生
    @RequestMapping("/student/exportCheckedStudent.do")
    public void exportCheckedStudent(HttpServletResponse response, String[] id) throws IOException {
        // 调用service层方法，查询勾选的市场活动
        List<Student> studentList = studentService.getStudentByIds(id);
        // 创建excel文件，并且把studentList写入到excel文件中
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("学生信息列表");
        HSSFRow row = sheet.createRow(0);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("学号");
        cell = row.createCell(1);
        cell.setCellValue("姓名");
        cell = row.createCell(2);
        cell.setCellValue("密码");
        cell = row.createCell(3);
        cell.setCellValue("性别");
        cell = row.createCell(4);
        cell.setCellValue("邮箱");
        cell = row.createCell(5);
        cell.setCellValue("手机号");
        cell = row.createCell(6);
        cell.setCellValue("专业");
        cell = row.createCell(7);
        cell.setCellValue("班级");
        cell = row.createCell(8);
        cell.setCellValue("地址");

        if (studentList != null && studentList.size() > 0){
            Student student = null;
            // 遍历activityList，创建HSSFRow对象，生成所有数据行
            for (int i = 0; i < studentList.size(); i++){
                student = studentList.get(i);
                // 每遍历一个activity，生成一行
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(student.getId_number());
                cell = row.createCell(1);
                cell.setCellValue(student.getName());
                cell = row.createCell(2);
                cell.setCellValue(student.getPassword());
                cell = row.createCell(3);
                cell.setCellValue(student.getSex());
                cell = row.createCell(4);
                cell.setCellValue(student.getEmail());
                cell = row.createCell(5);
                cell.setCellValue(student.getPhone());
                cell = row.createCell(6);
                cell.setCellValue(student.getDep_id());
                cell = row.createCell(7);
                cell.setCellValue(student.getClass_id());
                cell = row.createCell(8);
                cell.setCellValue(student.getAddress());
            }
        }

        // 把生成的excel文件下载到客户端
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=studentList.xls");
        OutputStream out = response.getOutputStream();

        wb.write(out);

        wb.close();
        out.flush();
    }

    // 导出未打卡学生
    @RequestMapping("/student/exportNotClockStudents.do")
    public void exportNotClockStudents(HttpServletResponse response) throws IOException {
        // 调用service层方法，查询勾选的市场活动
        List<Student> studentList = studentService.getNotClockStudents();
        // 创建excel文件，并且把studentList写入到excel文件中
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("学生信息列表");
        HSSFRow row = sheet.createRow(0);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("学号");
        cell = row.createCell(1);
        cell.setCellValue("姓名");
        cell = row.createCell(2);
        cell.setCellValue("密码");
        cell = row.createCell(3);
        cell.setCellValue("性别");
        cell = row.createCell(4);
        cell.setCellValue("邮箱");
        cell = row.createCell(5);
        cell.setCellValue("手机号");
        cell = row.createCell(6);
        cell.setCellValue("系部");
        cell = row.createCell(7);
        cell.setCellValue("班级");
        cell = row.createCell(8);
        cell.setCellValue("地址");

        if (studentList != null && studentList.size() > 0){
            Student student = null;
            // 遍历activityList，创建HSSFRow对象，生成所有数据行
            for (int i = 0; i < studentList.size(); i++){
                student = studentList.get(i);
                // 每遍历一个activity，生成一行
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(student.getId_number());
                cell = row.createCell(1);
                cell.setCellValue(student.getName());
                cell = row.createCell(2);
                cell.setCellValue(student.getPassword());
                cell = row.createCell(3);
                cell.setCellValue(student.getSex());
                cell = row.createCell(4);
                cell.setCellValue(student.getEmail());
                cell = row.createCell(5);
                cell.setCellValue(student.getPhone());
                cell = row.createCell(6);
                cell.setCellValue(student.getDep_id());
                cell = row.createCell(7);
                cell.setCellValue(student.getClass_id());
                cell = row.createCell(8);
                cell.setCellValue(student.getAddress());
            }
        }

        // 把生成的excel文件下载到客户端
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=notClock.xls");
        OutputStream out = response.getOutputStream();

        wb.write(out);

        wb.close();
        out.flush();
    }

    // 导出未提交行程码学生
    @RequestMapping("/student/exportNotTourStudents.do")
    public void exportNotTourStudents(HttpServletResponse response) throws IOException {
        // 调用service层方法，查询勾选的市场活动
        List<Student> studentList = studentService.getNotTourStudents();
        // 创建excel文件，并且把studentList写入到excel文件中
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("学生信息列表");
        HSSFRow row = sheet.createRow(0);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("学号");
        cell = row.createCell(1);
        cell.setCellValue("姓名");
        cell = row.createCell(2);
        cell.setCellValue("密码");
        cell = row.createCell(3);
        cell.setCellValue("性别");
        cell = row.createCell(4);
        cell.setCellValue("邮箱");
        cell = row.createCell(5);
        cell.setCellValue("手机号");
        cell = row.createCell(6);
        cell.setCellValue("系部");
        cell = row.createCell(7);
        cell.setCellValue("班级");
        cell = row.createCell(8);
        cell.setCellValue("地址");

        if (studentList != null && studentList.size() > 0){
            Student student = null;
            // 遍历activityList，创建HSSFRow对象，生成所有数据行
            for (int i = 0; i < studentList.size(); i++){
                student = studentList.get(i);
                // 每遍历一个activity，生成一行
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(student.getId_number());
                cell = row.createCell(1);
                cell.setCellValue(student.getName());
                cell = row.createCell(2);
                cell.setCellValue(student.getPassword());
                cell = row.createCell(3);
                cell.setCellValue(student.getSex());
                cell = row.createCell(4);
                cell.setCellValue(student.getEmail());
                cell = row.createCell(5);
                cell.setCellValue(student.getPhone());
                cell = row.createCell(6);
                cell.setCellValue(student.getDep_id());
                cell = row.createCell(7);
                cell.setCellValue(student.getClass_id());
                cell = row.createCell(8);
                cell.setCellValue(student.getAddress());
            }
        }

        // 把生成的excel文件下载到客户端
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=notTour.xls");
        OutputStream out = response.getOutputStream();

        wb.write(out);

        wb.close();
        out.flush();
    }

    // 导出未提交健康码码学生
    @RequestMapping("/student/exportNotHealthStudents.do")
    public void exportNotHealthStudents(HttpServletResponse response) throws IOException {
        // 调用service层方法，查询勾选的市场活动
        List<Student> studentList = studentService.getNotHealthStudents();
        // 创建excel文件，并且把studentList写入到excel文件中
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("学生信息列表");
        HSSFRow row = sheet.createRow(0);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("学号");
        cell = row.createCell(1);
        cell.setCellValue("姓名");
        cell = row.createCell(2);
        cell.setCellValue("密码");
        cell = row.createCell(3);
        cell.setCellValue("性别");
        cell = row.createCell(4);
        cell.setCellValue("邮箱");
        cell = row.createCell(5);
        cell.setCellValue("手机号");
        cell = row.createCell(6);
        cell.setCellValue("系部");
        cell = row.createCell(7);
        cell.setCellValue("班级");
        cell = row.createCell(8);
        cell.setCellValue("地址");

        if (studentList != null && studentList.size() > 0){
            Student student = null;
            // 遍历activityList，创建HSSFRow对象，生成所有数据行
            for (int i = 0; i < studentList.size(); i++){
                student = studentList.get(i);
                // 每遍历一个activity，生成一行
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(student.getId_number());
                cell = row.createCell(1);
                cell.setCellValue(student.getName());
                cell = row.createCell(2);
                cell.setCellValue(student.getPassword());
                cell = row.createCell(3);
                cell.setCellValue(student.getSex());
                cell = row.createCell(4);
                cell.setCellValue(student.getEmail());
                cell = row.createCell(5);
                cell.setCellValue(student.getPhone());
                cell = row.createCell(6);
                cell.setCellValue(student.getDep_id());
                cell = row.createCell(7);
                cell.setCellValue(student.getClass_id());
                cell = row.createCell(8);
                cell.setCellValue(student.getAddress());
            }
        }

        // 把生成的excel文件下载到客户端
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=notHealth.xls");
        OutputStream out = response.getOutputStream();

        wb.write(out);

        wb.close();
        out.flush();
    }


    // 导入学生
    @ResponseBody
    @RequestMapping("/student/importStudents.do")
    public Object importStudents(MultipartFile studentFile, HttpSession session){
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();

        try {
            InputStream is = studentFile.getInputStream();
            HSSFWorkbook wb = new HSSFWorkbook(is);
            HSSFSheet sheet = wb.getSheetAt(0); // 页的下标，下标从0开始，依次递增
            // 根据sheet获取HSSFRow对象，封装了一行所有的信息
            HSSFRow row = null;
            HSSFCell cell = null;
            Student student = null;
            List<Student> studentList = new ArrayList<>();
            for (int i = 1; i <= sheet.getLastRowNum(); i++){
                row = sheet.getRow(i);  // 行的下标，下标从0开始，依次增加
                student = new Student();
                for (int j = 0; j < row.getLastCellNum(); j++){
                    cell = row.getCell(j); // 列的下标，下标从0开始，依次增加
                    // 获取列中的数据
                    String cellValue = HSSFUtils.getCellValueForStr(cell);
                    if (j == 1){
                        student.setName(cellValue);
                    } else if (j == 2){
                        student.setPassword(cellValue);
                    } else if (j == 3){
                        student.setSex(cellValue);
                    } else if (j == 4){
                        student.setEmail(cellValue);
                    } else if (j == 5){
                        student.setPhone(cellValue);
                    } else if (j == 6){
                        student.setDep_id(cellValue);
                    } else if (j == 7){
                        student.setClass_id(cellValue);
                    } else if (j == 8){
                        student.setAddress(cellValue);
                    }
                }
                student.setCreateBy(admin.getName());
                // 每一行中所有列封装完之后，把activity保存到list中
                studentList.add(student);
            }

            // 调用service层方法，保存市场活动
            returnObject = studentService.saveStudents(studentList);
        } catch (Exception e){
            returnObject.setCode("310");
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    // 一键重置学生密码
    @ResponseBody
    @RequestMapping(value = "/student/resetStudentPassword.do")
    public Object resetStudentPassword(HttpSession session) {
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);
        Student student = new Student();
        ReturnObject returnObject = new ReturnObject();

        student.setPassword("000000");
        student.setEditBy(admin.getName());
        student.setEditTime(DateUtils.formateDateTime(new Date()));

        boolean flag = studentService.resetPassword(student);
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("重置密码成功！");
        }else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙,请稍后重试...");
        }
        return returnObject;
    }

    // 一键重置教师密码
    @ResponseBody
    @RequestMapping(value = "/teacher/resetTeacherPassword.do")
    public Object resetTeacherPassword(HttpSession session) {
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);
        Teacher teacher = new Teacher();
        ReturnObject returnObject = new ReturnObject();

        teacher.setPassword("000000");
        teacher.setEditBy(admin.getName());
        teacher.setEditTime(DateUtils.formateDateTime(new Date()));

        boolean flag = teacherService.resetPassword(teacher);
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("重置密码成功！");
        }else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙,请稍后重试...");
        }
        return returnObject;
    }

    // 重置健康码和行程码
    @ResponseBody
    @RequestMapping(value = "/student/resetHealthAndTourCode.do")
    public Object resetHealthAndTourCode(HttpSession session) {
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);
        Student student = new Student();
        ReturnObject returnObject = new ReturnObject();

        student.setTourCode("");
        student.setHealthCode("");
        student.setEditBy(admin.getName());
        student.setEditTime(DateUtils.formateDateTime(new Date()));

        boolean flag = studentService.resetHealthAndTourCode(student);
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("重置健康码和行程码成功！");
        }else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙,请稍后重试...");
        }
        return returnObject;
    }

    // 重置打卡
    @ResponseBody
    @RequestMapping(value = "/student/resetPunch.do")
    public Object resetPunch(HttpSession session) {
        Admin admin = (Admin) session.getAttribute(Contants.SESSION_USER);
        Student student = new Student();
        ReturnObject returnObject = new ReturnObject();

        student.setIsClock("0");
        student.setEditBy(admin.getName());
        student.setEditTime(DateUtils.formateDateTime(new Date()));

        boolean flag = studentService.resetPunch(student);
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("重置打卡状态成功！");
        }else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙,请稍后重试...");
        }
        return returnObject;
    }

    // 根据条件查找请假
    @ResponseBody
    @RequestMapping(value = "/student/queryLeaveByCondition.do")
    public PageInfo<Leave> queryLeaveByCondition(Integer page, Integer pageSize, Leave leave) {
        PageHelper.startPage(page, pageSize);
        List<Leave> leaveList = leaveService.getLeavesByCondition(leave);
        PageInfo<Leave> pageInfo = new PageInfo<>(leaveList);
        return pageInfo;
    }

    // 单个删除请假
    @ResponseBody
    @RequestMapping(value = "/leave/deleteLeaveById.do")
    public Object deleteLeaveById(String id){
        boolean flag = leaveService.deleteLeaveById(id);
        ReturnObject returnObject = new ReturnObject();
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("删除假条成功");
        }else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后再试...");
        }
        return returnObject;
    }

    // 删除多个请假
    @ResponseBody
    @RequestMapping(value = "/leave/deleteLeaveByIds.do")
    public Object deleteLeaveByIds(String ids){
        // 将字符串以','分割保存到数组中
        String[] d = ids.split(",");
        boolean flag = leaveService.deleteLeaveByIds(d);
        ReturnObject returnObject = new ReturnObject();
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("删除假条成功");
        }else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后再试...");
        }
        return returnObject;
    }


    // 请假审批
    @ResponseBody
    @RequestMapping(value = "/leave/approval.do")
    public Object approval(String id, HttpSession session){
        String approver = ((Admin) session.getAttribute(Contants.SESSION_USER)).getId();
        boolean flag = leaveService.approval(id, approver);
        ReturnObject returnObject = new ReturnObject();
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("审批成功");
        }else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后再试...");
        }
        return returnObject;
    }

}
