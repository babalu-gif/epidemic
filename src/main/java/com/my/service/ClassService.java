package com.my.service;

import com.my.entity.Class;

import java.util.List;

public interface ClassService {
    List<String> queryClassByName();

    List<Class> queryAllClass();

    List<Class> queryClassByDepCode(String dep_code);

    Class queryClassById(String id);
}
