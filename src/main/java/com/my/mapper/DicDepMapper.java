package com.my.mapper;

import com.my.entity.DicDep;

import java.util.List;

public interface DicDepMapper {
    List<DicDep> getAllDicDep();

    DicDep queryDicDepByShortName(String short_name);
}
