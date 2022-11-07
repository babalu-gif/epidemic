package com.my.utils;

import javax.mail.Address;
import javax.mail.Session;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Date;

public class SendEmailUtil {
    public static MimeMessage createEmail(Session session, String users, String content, InternetAddress fromAddress) throws Exception {
        // 根据会话创建邮件
        MimeMessage msg = new MimeMessage(session);
        // 设置发送邮件方
        msg.setFrom(fromAddress);
        // 设置邮件接收方
        Address[] internetAddressTo = new InternetAddress().parse(users);
        msg.setRecipients(MimeMessage.RecipientType.TO,  internetAddressTo);
        // 设置邮件标题
        msg.setSubject("体温打卡", "utf-8");
        msg.setContent(content, "text/html;charset=utf-8");

        // 设置显示的发件时间
        msg.setSentDate(new Date());
        // 保存设置
        msg.saveChanges();
        return msg;
    }

}