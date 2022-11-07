package com.my.service;

import com.my.entity.DicDep;

import java.util.List;

public interface DicDepService {
    List<DicDep> getAllDicDep();

    DicDep getDicDepByShortName(String short_name);
}
