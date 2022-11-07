package com.my.mapper;

import com.my.entity.Class;
import com.my.entity.DicPro;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ClassMapper {
    List<String> queryAllClassName();

    Class selectClassByName(String name);

    int insertClass(Class c);

    List<Class> queryAllClass();

    List<Class> queryClassByDepCode(String dep_code);

    int queryClassNumberByName(String name);

    int updateClassNumber(@Param("id") String id, @Param("number") String number);

    Class queryClassById(String id);
}
