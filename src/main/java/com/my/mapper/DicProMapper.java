package com.my.mapper;

import com.my.entity.DicPro;

public interface DicProMapper {
    DicPro queryDicProByShortName(String short_name);
}
