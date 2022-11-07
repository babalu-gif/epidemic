package com.my.mapper;

import com.my.entity.Admin;
import com.my.entity.Teacher;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface AdminMapper {

    Admin login(@Param("userName") String userName, @Param("password") String password);

    int setPwd(Admin admin);

    List<Teacher> getTeachers(Teacher teacher);
}
