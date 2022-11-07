package com.my.controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.my.contants.Contants;
import com.my.entity.*;
import com.my.service.LeaveService;
import com.my.service.StudentService;
import com.my.service.TeacherService;
import com.my.utils.FileNameUtil;
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
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/teacher")
public class TeacherController {

    @Resource
    private TeacherService teacherService;
    @Resource
    private StudentService studentService;
    @Resource
    private LeaveService leaveService;

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


    @RequestMapping(value = "/toMain.do")
    public String toMain(){
        return "teacher/toMain";
    }

    @RequestMapping(value = "/toHealthPunch.do")
    public String toHealthPunch(){
        return "teacher/healthPunch";
    }

    @RequestMapping(value = "/toLeave.do")
    public String toLeave(){
        return "teacher/leaveSystem";
    }

    // 更新密码
    @ResponseBody
    @RequestMapping(value = "/updatePwd.do")
    public Object updatePwd(Teacher teacher, HttpSession session, HttpServletResponse response){
        boolean flag = teacherService.setPwd(teacher);
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

    // 更新头像
    @ResponseBody
    @RequestMapping(value = "/setAvatar.do")
    public Object setAvatar(String id, String avatar){
        boolean flag = teacherService.setAvatar(id, avatar);
        ReturnObject returnObject = new ReturnObject();
        if (flag == true){
            returnObject.setCode("200");
            returnObject.setMessage("头像修改成功！");
        } else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping(value = "/toState.do")
    public String toState() {
        return "list/state";
    }

    @RequestMapping(value = "/toStudent.do")
    public String toStudent() {
        return "teacher/student";
    }

    // 根据条件查找学生
    @ResponseBody
    @RequestMapping(value = "/getStudentByTeacherClassId.do")
    public PageInfo<Student> getStudentByTeacherClassId(Integer page, Integer pageSize, Student student, String ci) {
        PageHelper.startPage(page, pageSize);
        List<Student> studentList = teacherService.getStudentByTeacherClassId(student, ci);
        PageInfo<Student> pageInfo = new PageInfo<>(studentList);
        return pageInfo;
    }

    // 根据id查询学生信息
    @ResponseBody
    @RequestMapping(value = "/queryStudentById.do")
    public Object queryStudentById(String id){
        ReturnObject returnObject = new ReturnObject();
        Student student = studentService.queryStudentById(id);
        returnObject.setRetData(student);
        return returnObject;
    }

    // 导出所有学生
    @RequestMapping("/exportAllStudents.do")
    public void exportAllStudents(HttpServletResponse response, String ci) throws IOException {
        // 调用service层方法，查询勾选的市场活动
        List<Student> studentList = studentService.queryAllStudentsByClassId(ci);
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
    @RequestMapping("/exportCheckedStudent.do")
    public void exportCheckedStudent(HttpServletResponse response, String[] id) throws IOException {
        // 调用service层方法，查询勾选的市场活动
        List<Student> studentList = studentService.queryAllStudentsByClassId(id);
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

    // 异步ajax文件上传处理（教师头像）
    @ResponseBody
    @RequestMapping(value = "/ajaxImg.do")
    public Object ajaxImg(HttpServletRequest request, MultipartFile teacherImage) {
        saveFileName = FileNameUtil.getUUIDFileName()+FileNameUtil.getFileType(teacherImage.getOriginalFilename());

        if (!AVATAR_TYPES.contains(teacherImage.getContentType())){
            JSONObject object = new JSONObject();
            object.put("code", "303");
            object.put("message", "Allowed file types:" + AVATAR_TYPES);
            return object.toString();
        }

        // 得到项目中图片存储的路径
        String path = request.getServletContext().getRealPath("upload");
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

    // 根据条件查找请假
    @ResponseBody
    @RequestMapping(value = "/queryLeaveByConditionAndClassId.do")
    public PageInfo<Leave> queryLeaveByCondition(Integer page, Integer pageSize, Leave leave, String ci) {
        String[] studentIds= studentService.queryStudentsByClassId(ci);
        PageHelper.startPage(page, pageSize);
        List<Leave> leaveList = leaveService.getLeavesByConditionAndClassId(leave, studentIds);
        PageInfo<Leave> pageInfo = new PageInfo<>(leaveList);
        return pageInfo;
    }

    // 请假审批
    @ResponseBody
    @RequestMapping(value = "/leave/approval.do")
    public Object approval(String id, HttpSession session){
        String approver = ((Teacher) session.getAttribute(Contants.SESSION_TEACHER)).getId();
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


    // 根据条件查找健康打卡
    @ResponseBody
    @RequestMapping(value = "/queryPunchByConditionAndClassId.do")
    public PageInfo<Student> queryPunchByConditionAndClassId(Integer page, Integer pageSize, Student student, String ci) {
        String[] studentIds = studentService.queryStudentsByClassId(ci);
        PageHelper.startPage(page, pageSize);
        List<Student> studentList = teacherService.getPunchByConditionAndClassId(student, studentIds);
        PageInfo<Student> pageInfo = new PageInfo<>(studentList);
        return pageInfo;
    }

    // 导出未打卡学生
    @RequestMapping("/exportNotClockStudents.do")
    public void exportNotClockStudents(HttpServletResponse response, String ci) throws IOException {
        String[] studentIds = studentService.queryStudentsByClassId(ci);
        List<Student> studentList = studentService.getNotTourStudentsByStudentIds(studentIds);
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
    @RequestMapping("/exportNotTourStudents.do")
    public void exportNotTourStudents(HttpServletResponse response, String ci) throws IOException {
        String[] studentIds = studentService.queryStudentsByClassId(ci);
        List<Student> studentList = studentService.getNotClockStudentsByStudentIds(studentIds);
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
    @RequestMapping("/exportNotHealthStudents.do")
    public void exportNotHealthStudents(HttpServletResponse response, String ci) throws IOException {
        String[] studentIds = studentService.queryStudentsByClassId(ci);
        List<Student> studentList = studentService.getNotHealthStudentsByStudentIds(studentIds);
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




}
