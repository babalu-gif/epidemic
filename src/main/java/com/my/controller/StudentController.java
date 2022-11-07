package com.my.controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.my.contants.Contants;
import com.my.entity.Admin;
import com.my.entity.Leave;
import com.my.entity.ReturnObject;
import com.my.entity.Student;
import com.my.service.LeaveService;
import com.my.service.StudentService;
import com.my.utils.FileNameUtil;
import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/student")
public class StudentController {

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

    // 跳转学生主页面
    @RequestMapping(value = "/toMain.do")
    public String toMain(){
        return "student/toMain";
    }

    // 跳转学生的请假
    @RequestMapping(value = "/toLeave.do")
    public String toLeave(){
        return "student/leaveSystem";
    }

    // 跳转学生的双码
    @RequestMapping(value = "/toCode.do")
    public String toCode(){
        return "student/code";
    }


    // 更新学生密码
    @ResponseBody
    @RequestMapping("/updatePwd.do")
    public Object updatePwd(String id, String password){
        boolean flag = studentService.setStudentPwd(id, password);
        ReturnObject returnObject = new ReturnObject();
        if (flag){
            returnObject.setCode("200");
        } else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请稍后再试...");
        }
        return returnObject;
    }

    // 查询学生信息
    @ResponseBody
    @RequestMapping("/queryStudentById.do")
    public Object queryStudentById(String id){
        Student student = studentService.queryStudentById(id);
        ReturnObject returnObject = new ReturnObject();
        returnObject.setRetData(student);
        return returnObject;
    }

    // 异步ajax文件上传处理（学生头像）
    @ResponseBody
    @RequestMapping(value = "/ajaxImg.do")
    public Object ajaxImg(HttpServletRequest request, MultipartFile studentImage) {
        saveFileName = FileNameUtil.getUUIDFileName()+FileNameUtil.getFileType(studentImage.getOriginalFilename());

        if (!AVATAR_TYPES.contains(studentImage.getContentType())){
            JSONObject object = new JSONObject();
            object.put("code", "303");
            object.put("message", "Allowed file types:" + AVATAR_TYPES);
            return object.toString();
        }

        // 得到项目中图片存储的路径
        String path = request.getServletContext().getRealPath("upload");
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

    // 异步ajax文件上传处理（健康码）
    @ResponseBody
    @RequestMapping(value = "/ajaxHealthCodeImage.do")
    public Object ajaxHealthCodeImage(HttpServletRequest request, MultipartFile healthCodeImage) {
        saveFileName = FileNameUtil.getUUIDFileName()+FileNameUtil.getFileType(healthCodeImage.getOriginalFilename());

        if (!AVATAR_TYPES.contains(healthCodeImage.getContentType())){
            JSONObject object = new JSONObject();
            object.put("code", "303");
            object.put("message", "Allowed file types:" + AVATAR_TYPES);
            return object.toString();
        }

        // 得到项目中图片存储的路径
        String path = request.getServletContext().getRealPath("upload");
        // 转存
        try {
            healthCodeImage.transferTo(new File(path + File.separator + saveFileName));
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 返回给客户端JSON对象，封装图片的路径，为了在页面实现立即回显
        JSONObject object = new JSONObject();
        object.put("retData", saveFileName);
        object.put("code", "200");
        return object.toString();
    }

    // 异步ajax文件上传处理（行程码）
    @ResponseBody
    @RequestMapping(value = "/ajaxTourCodeImage.do")
    public Object ajaxTourCodeImage(HttpServletRequest request, MultipartFile tourCodeImage) {
        saveFileName = FileNameUtil.getUUIDFileName()+FileNameUtil.getFileType(tourCodeImage.getOriginalFilename());

        if (!AVATAR_TYPES.contains(tourCodeImage.getContentType())){
            JSONObject object = new JSONObject();
            object.put("code", "303");
            object.put("message", "Allowed file types:" + AVATAR_TYPES);
            return object.toString();
        }

        // 得到项目中图片存储的路径
        String path = request.getServletContext().getRealPath("upload");
        // 转存
        try {
            tourCodeImage.transferTo(new File(path + File.separator + saveFileName));
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 返回给客户端JSON对象，封装图片的路径，为了在页面实现立即回显
        JSONObject object = new JSONObject();
        object.put("retData", saveFileName);
        object.put("code", "200");

        return object.toString();
    }

    // 更新健康码
    @ResponseBody
    @RequestMapping("/setHealthCode.do")
    public Object setHealthCode(String id, String healthCode){
        boolean flag = studentService.updateHealthCode(id, healthCode);
        ReturnObject returnObject = new ReturnObject();
        if (flag == true){
            returnObject.setCode("200");
            returnObject.setMessage("健康码修改成功！");
        } else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    // 更新行程码
    @ResponseBody
    @RequestMapping("/setTourCode.do")
    public Object setTourCode(String id, String tourCode){
        boolean flag = studentService.updateTourCode(id, tourCode);
        ReturnObject returnObject = new ReturnObject();
        if (flag == true){
            returnObject.setCode("200");
            returnObject.setMessage("行程码修改成功！");
        } else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    // 更新头像
    @ResponseBody
    @RequestMapping(value = "/setAvatar.do")
    public Object setAvatar(String id, String avatar){
        boolean flag = studentService.setStudentAvatar(id, avatar);
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

    @ResponseBody
    @RequestMapping(value = "/punch.do")
    public Object punch(String id){
        boolean flag = studentService.punch(id);
        ReturnObject returnObject = new ReturnObject();
        if (flag == true){
            returnObject.setCode("200");
            returnObject.setMessage("打卡成功！");
        } else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

    // 根据条件查找请假记录
    @ResponseBody
    @RequestMapping(value = "/getLeavesByConditionAndStudentId.do")
    public PageInfo<Leave> getLeavesByConditionAndStudentId(Integer page, Integer pageSize, Leave leave) {
        PageHelper.startPage(page, pageSize);
        List<Leave> leaveList = leaveService.getLeavesByConditionAndStudentId(leave);
        PageInfo<Leave> pageInfo = new PageInfo<>(leaveList);
        return pageInfo;
    }

    @ResponseBody
    @RequestMapping("/saveLeave.do")
    public Object saveLeave(Leave leave){
        ReturnObject returnObject = new ReturnObject();
        boolean flag = leaveService.saveLeave(leave);
        if (flag){
            returnObject.setCode("200");
            returnObject.setMessage("添加成功！");
        } else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请稍后重试...");
        }
        return returnObject;
    }

}
