package com.my.service.impl;

import com.my.entity.Class;
import com.my.mapper.ClassMapper;
import com.my.service.ClassService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class ClassServiceImpl implements ClassService {

    @Resource
    private ClassMapper classMapper;

    @Override
    public List<String> queryClassByName() {
        return classMapper.queryAllClassName();
    }

    @Override
    public List<Class> queryAllClass() {
        return classMapper.queryAllClass();
    }

    @Override
    public List<Class> queryClassByDepCode(String dep_code) {
        return classMapper.queryClassByDepCode(dep_code);
    }

    @Override
    public Class queryClassById(String id) {
        return classMapper.queryClassById(id);
    }
}
