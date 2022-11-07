package com.my.controller;

import com.my.entity.ReturnObject;
import com.my.entity.Student;
import com.my.service.StudentService;
import com.my.utils.SendEmailUtil;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.PropertySource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
@PropertySource("classpath:jdbc.properties")
@Controller
public class SendEmailController {

    @Value("${mail.smtp.username}")
    private String SENDER; //账户名:我的是qq账户,此账户必须在设置中开启授权码授权
    @Value("${mail.smtp.password}")
    private String PWD; //授权密码
    @Value("${mail.smtp.host}") //从属性文件中获取值其中key为smtp.host
    private String SMTPSERVER;
    @Value("${mail.smtp.port}") //端口号 465  465  465   不是456
    private String SMTPPORT;

    @Autowired
    private JavaMailSender javaMailSender;//在spring中配置的邮件发送的bean
    @Resource
    private StudentService studentService;

    /*@ResponseBody
    @RequestMapping(value = "/admin/student/sendEmailToNotClock.do")
    public Object sendEmailToNotClock(){
        ReturnObject returnObject = new ReturnObject();
        List<Student> studentList = studentService.getNotClockStudents();
        MimeMessage mMessage = javaMailSender.createMimeMessage();//创建邮件对象
        MimeMessageHelper mMessageHelper;

        //Properties prop = new Properties();


        System.out.println("=================");
        System.out.println("=================");
        System.out.println("=================");
        System.out.println(SENDER);
        System.out.println(SMTPSERVER);
        System.out.println(PWD);
        System.out.println(SMTPPORT);

        for (Student student : studentList){
            if (!"".equals(student.getEmail()))
                try {

                    //prop.load(this.getClass().getResourceAsStream("/email.properties"));
                    //String from = prop.get("mail.smtp.username")+"";
                    mMessageHelper = new MimeMessageHelper(mMessage,true);
                    mMessageHelper.setFrom(SENDER);//发件人邮箱
                    mMessageHelper.setSentDate(new Date());

                    mMessageHelper.setTo(student.getEmail());//收件人邮箱
                    mMessageHelper.setSubject("打卡通知");//邮件的主题
                    mMessageHelper.setText("<p>今日打卡未完成，请尽快打卡！！！</p><br/>" +
                            "<a href='http://49.233.250.224:8080/yaodian/login/'>登录打卡系统</a><br/>",true);//邮件的文本内容，true表示文本以html格式打开
                    javaMailSender.send(mMessage);//发送邮件

                    returnObject.setCode("200");
                    returnObject.setMessage("发送邮件成功！");
                } catch (MessagingException e) {
                    e.printStackTrace();
                    returnObject.setCode("400");
                    returnObject.setMessage("系统忙,请稍后重试...");
                }
        }

        return returnObject;
    }*/

    @ResponseBody
    @RequestMapping(value = "/admin/student/sendEmailToNotClock.do")
    public Object sendEmailToNotClock(){
        ReturnObject returnObject = new ReturnObject();
        try {
            // 创建邮件配置
            Properties props = new Properties();
            props.setProperty("mail.transport.protocol", "smtp"); // 使用的协议（JavaMail规范要求）
            props.setProperty("mail.smtp.host", SMTPSERVER); // 发件人的邮箱的 SMTP 服务器地址
            props.setProperty("mail.smtp.port", SMTPPORT);
            props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
            props.setProperty("mail.smtp.auth", "true"); // 需要请求认证
            props.setProperty("mail.smtp.ssl.enable", "true");// 开启ssl
            // 根据邮件配置创建会话，注意session别导错包
            Session session = Session.getDefaultInstance(props);
            // 开启debug模式，可以看到更多详细的输入日志
            session.setDebug(true);
            // address邮件地址, personal邮件昵称, charset编码方式
            InternetAddress fromAddress = new InternetAddress(SENDER,
                    "管理员", "utf-8");

            List<Student> studentList = studentService.getNotClockStudents();
            ArrayList<String> arrayList = new ArrayList<>();
            for (Student student : studentList){
                if (!"".equals(student.getEmail()))
                    arrayList.add(student.getEmail());
            }
            // 将集合以逗号分割为字符串
            String students = StringUtils.join(arrayList, ",");
            String text = "<p>今日打卡未完成，请尽快打卡！！！</p><br/>" +
                    "<a href='http://101.132.169.6:8080/epidemi/login.jsp'>登录打卡系统</a><br/>";//邮件的文本内容，true表示文本以html格式打开
            //创建邮件
            MimeMessage message = SendEmailUtil.createEmail(session, students, text, fromAddress);   //将用户和内容传递过来
            //获取传输通道
            Transport transport = session.getTransport();
            transport.connect(SMTPSERVER,SENDER, PWD);
            //连接，并发送邮件
            transport.sendMessage(message, message.getAllRecipients());
            transport.close();

            returnObject.setCode("200");
            returnObject.setMessage("发送邮件成功！");
        } catch (Exception e) {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙,请稍后重试...");
            e.printStackTrace();
        }
        return returnObject;
    }

    @ResponseBody
    @RequestMapping(value = "/teacher/sendEmailToNotClock.do")
    public Object sendEmailToNotClock2(String ci){
        ReturnObject returnObject = new ReturnObject();
        try {
            // 创建邮件配置
            Properties props = new Properties();
            props.setProperty("mail.transport.protocol", "smtp"); // 使用的协议（JavaMail规范要求）
            props.setProperty("mail.smtp.host", SMTPSERVER); // 发件人的邮箱的 SMTP 服务器地址
            props.setProperty("mail.smtp.port", SMTPPORT);
            props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
            props.setProperty("mail.smtp.auth", "true"); // 需要请求认证
            props.setProperty("mail.smtp.ssl.enable", "true");// 开启ssl
            // 根据邮件配置创建会话，注意session别导错包
            Session session = Session.getDefaultInstance(props);
            // 开启debug模式，可以看到更多详细的输入日志
            session.setDebug(true);
            // address邮件地址, personal邮件昵称, charset编码方式
            InternetAddress fromAddress = new InternetAddress(SENDER,
                    "教师", "utf-8");

            String[] studentIds = studentService.queryStudentsByClassId(ci);
            List<Student> studentList = studentService.getNotClockStudentsByStudentIds(studentIds);
            ArrayList<String> arrayList = new ArrayList<>();
            for (Student student : studentList){
                if (!"".equals(student.getEmail()))
                    arrayList.add(student.getEmail());
            }
            // 将集合以逗号分割为字符串
            String students = StringUtils.join(arrayList, ",");
            String text = "<p>今日打卡未完成，请尽快打卡！！！</p><br/>" +
                    "<a href='http://47.99.69.212:8080/epidemi/login.jsp'>登录打卡系统</a><br/>";//邮件的文本内容，true表示文本以html格式打开
            //创建邮件
            MimeMessage message = SendEmailUtil.createEmail(session, students, text, fromAddress);   //将用户和内容传递过来
            //获取传输通道
            Transport transport = session.getTransport();
            transport.connect(SMTPSERVER,SENDER, PWD);
            //连接，并发送邮件
            transport.sendMessage(message, message.getAllRecipients());
            transport.close();

            returnObject.setCode("200");
            returnObject.setMessage("发送邮件成功！");
        } catch (Exception e) {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙,请稍后重试...");
            e.printStackTrace();
        }
        return returnObject;
    }



}
