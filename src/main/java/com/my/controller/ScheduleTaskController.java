package com.my.controller;

import com.my.service.StudentService;
import com.my.utils.DateUtils;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.Date;

@Configuration
@Component
@EnableScheduling // 开启定时任务
public class ScheduleTaskController {

    @Resource
    private StudentService studentService;
    //添加定时任务 每5秒执行一次
    @Scheduled(cron = "0 */1 * * * ?")
    // 每天13:00执行一次
    // @Scheduled(cron = "0 0 13 * * ?")
    //或直接指定时间间隔，例如：5秒
    //@Scheduled(fixedRate=5000)
    public void configureTasks() {
        /*Student student = new Student();
        student.setIsClock("0");
        student.setEditTime(DateUtils.formateDateTime(new Date()));
        studentService.resetPunch(student);
        System.out.println("执行静态定时任务时间: " + DateUtils.formateDateTime(new Date()));*/
            System.out.println("执行静态定时任务时间: " + DateUtils.formateDateTime(new Date()));
        }

}
