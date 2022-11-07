package com.my.entity;

public class DicPro {
    private String code;
    private String name;
    private String short_name;
    private String dep_code;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getShort_name() {
        return short_name;
    }

    public void setShort_name(String short_name) {
        this.short_name = short_name;
    }

    public String getDep_code() {
        return dep_code;
    }

    public void setDep_code(String dep_code) {
        this.dep_code = dep_code;
    }

    @Override
    public String toString() {
        return "DicPro{" +
                "code='" + code + '\'' +
                ", name='" + name + '\'' +
                ", short_name='" + short_name + '\'' +
                ", dep_code='" + dep_code + '\'' +
                '}';
    }
}
