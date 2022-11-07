package com.my.service.impl;

import com.my.entity.DicDep;
import com.my.mapper.DicDepMapper;
import com.my.service.DicDepService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class DicDepServiceImpl implements DicDepService {

    @Resource
    private DicDepMapper dicDepMapper;

    @Override
    public List<DicDep> getAllDicDep() {
        return dicDepMapper.getAllDicDep();
    }

    public DicDep getDicDepByShortName(String short_name){
        return dicDepMapper.queryDicDepByShortName(short_name);
    };
}
