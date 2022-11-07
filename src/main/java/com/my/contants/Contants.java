package com.my.contants;

/***
 * 返回的code值，设为常量
 * 易于后期维护和修改
 */
public class Contants {
    // 保存ReturnObject类中的code值
    public static final String RETURN_OBJECT_SUCCESS = "1"; // 成功
    public static final String RETURN_OBJECT_FAIL = "0"; // 失败

    // 保存当前用户的key
    public static final String SESSION_USER = "sessionUser";
    public static final String SESSION_TEACHER = "sessionTeacher";
    public static final String SESSION_STUDENT = "sessionStudent";

    // 备注的修改标记
    public static final String REMARK_EDIT_NO = "0"; // 未修改
    public static final String REMARK_EDIT_YES = "1"; // 修改过
}
