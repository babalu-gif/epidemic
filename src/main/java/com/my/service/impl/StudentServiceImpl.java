package com.my.service.impl;

import com.my.entity.*;
import com.my.entity.Class;
import com.my.mapper.ClassMapper;
import com.my.mapper.DicDepMapper;
import com.my.mapper.DicProMapper;
import com.my.mapper.StudentMapper;
import com.my.service.DicDepService;
import com.my.service.StudentService;
import com.my.utils.DateUtils;
import com.my.utils.UUIDUtil;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.Date;
import java.util.List;

@Service
public class StudentServiceImpl implements StudentService {

    @Resource
    private StudentMapper studentMapper;
    @Resource
    private ClassMapper classMapper;
    @Resource
    private DicProMapper dicProMapper;
    @Resource
    private DicDepMapper dicDepMapper;

    @Override
    public ReturnObject saveStudent(Student student) {

        ReturnObject returnObject = new ReturnObject();

        String className = student.getClass_id();
        Class c = classMapper.selectClassByName(className);

        int count = classMapper.queryClassNumberByName(student.getClass_id());
        if ((count+"").length() == 1){
            count += 1;
            student.setId_number(className.substring(3, 5)+c.getPro_code()+className.substring(6, 7)+"0"+count);
        }
        if ((count+"").length() == 2){
            count += 1;
            student.setId_number(className.substring(3, 5)+c.getPro_code()+className.substring(6, 7)+count);
        }
        if (count >= 99){
            returnObject.setCode("311");
            returnObject.setMessage("每班人数最多99人！");
            return returnObject;
        }

        student.setClass_id(c.getId());
        student.setPro_id(c.getPro_code());
        student.setDep_id(c.getDep_code());
        student.setId(UUIDUtil.getUUID());
        student.setCreateBy(student.getCreateBy());
        student.setCreateTime(DateUtils.formateDateTime(new Date()));
        student.setPassword("000000");
        student.setLockState("1");
        student.setHealthCode("");
        student.setTourCode("");
        student.setIsClock("0");

        if ("未选择文件...".equals(student.getAvatar())){
            student.setAvatar("student.png");
        }

        int result = studentMapper.saveStudent(student);
        if (result == 0){
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后重试...");
            return returnObject;
        }
        returnObject.setCode("200");
        returnObject.setMessage("学生添加成功");

        // 学生添加成功，对应班级人数加1
        classMapper.updateClassNumber(c.getId(), count+"");
        return returnObject;
    }

    @Override
    public Student queryStudentById(String id) {
        return studentMapper.queryStudentById(id);
    }

    @Override
    public boolean deleteStudentByIds(String[] ids) {
        int result = studentMapper.deleteStudentByIds(ids);
        // 删除学生，班级人数减

        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean deleteStudentById(String id) {
        int result = studentMapper.deleteStudentById(id);

        // 删除学生，班级人数减1

        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public ReturnObject updateStudent(Student student) {
        ReturnObject returnObject = new ReturnObject();

        String className = student.getClass_id();
        Class c = classMapper.selectClassByName(className);
        student.setClass_id(c.getId());
        DicPro dicPro = dicProMapper.queryDicProByShortName(className.substring(0, 2));
        student.setPro_id(dicPro.getCode());
        DicDep dicDep = dicDepMapper.queryDicDepByShortName(student.getDep_id());
        student.setDep_id(dicDep.getCode());

        int result = studentMapper.updateStudent(student);
        if (result >= 1){
            returnObject.setCode("200");
            returnObject.setMessage("学生修改成功");
        } else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后重试...");
        }


        return returnObject;
    }

    @Override
    public List<Student> queryAllStudents() {
        return studentMapper.getAllStudents();
    }

    @Override
    public List<Student> getStudentByIds(String[] ids) {
        return studentMapper.getStudentByIds(ids);
    }

    @Override
    public List<Student> getStudents(Student student) {
        return studentMapper.getStudents(student);
    }

    @Override
    public List<Student> getNotClockStudents() {
        return studentMapper.getNotClockStudents();
    }

    @Override
    public List<Student> getNotClockStudentsByStudentIds(String[] studentIds) {
        return studentMapper.getNotClockStudentsByStudentIds(studentIds);
    }

    @Override
    public List<Student> getNotTourStudents() {
        return studentMapper.getNotTourStudents();
    }

    @Override
    public List<Student> getNotTourStudentsByStudentIds(String[] studentIds) {
        return studentMapper.getNotTourStudentsByStudentIds(studentIds);
    }

    @Override
    public List<Student> getNotHealthStudents() {
        return studentMapper.getNotHealthStudents();
    }

    @Override
    public List<Student> getNotHealthStudentsByStudentIds(String[] studentIds) {
        return studentMapper.getNotHealthStudentsByStudentIds(studentIds);
    }

    @Override
    public ReturnObject saveStudents(List<Student> studentList) {
        Date date = new Date();
        ReturnObject returnObject = new ReturnObject();
        Class c = new Class();
        DicPro dicPro = new DicPro();
        DicDep dicDep = new DicDep();

        for (Student student : studentList){
            String className = student.getClass_id();
            if ("".equals(className)){
                returnObject.setCode("314");
                returnObject.setMessage("班级不存在，导入学生失败！");
                return returnObject;
            }

            c = classMapper.selectClassByName(className);
            /*dicPro = dicProMapper.queryDicProByShortName(className.substring(0, 2));
            dicDep = dicDepMapper.queryDicDepByShortName(student.getDep_id());*/

            int count = classMapper.queryClassNumberByName(student.getClass_id());
            if ((count+"").length() == 1){
                count += 1;
                student.setId_number(className.substring(3, 5)+c.getPro_code()+className.substring(6, 7)+"0"+count);
            }
            if ((count+"").length() == 2){
                count += 1;
                student.setId_number(className.substring(3, 5)+c.getPro_code()+className.substring(6, 7)+count);
            }
            if (count >= 99){
                returnObject.setCode("311");
                returnObject.setMessage("每班人数最多99人！");
                return returnObject;
            }

            // 学生添加成功，对应班级人数加1
            classMapper.updateClassNumber(c.getId(), count+"");

            student.setClass_id(c.getId());
            student.setPro_id(c.getPro_code());
            student.setDep_id(c.getDep_code());
            student.setId(UUIDUtil.getUUID());
            student.setCreateBy(student.getCreateBy());
            student.setCreateTime(DateUtils.formateDateTime(date));
            student.setPassword("000000");
            student.setLockState("1");
            student.setHealthCode("");
            student.setTourCode("");
            student.setIsClock("0");

            if ("未选择文件...".equals(student.getAvatar())){
                student.setAvatar("student.png");
            }
        }

        int result = studentMapper.saveStudents(studentList);
        if (result >= 1){
            returnObject.setCode("200");
            returnObject.setMessage("成功导入"+result+"条数据");
        } else {
            returnObject.setCode("400");
            returnObject.setMessage("系统忙，请销后重试...");
        }
        return returnObject;
    }

    @Override
    public boolean resetPassword(Student student) {
        int result = studentMapper.resetPassword(student);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean resetHealthAndTourCode(Student student) {
        int result = studentMapper.resetHealthAndTourCode(student);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean resetPunch(Student student) {
        int result = studentMapper.resetPunch(student);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean updateHealthCode(String id, String saveFileName) {
        int result = studentMapper.updateHealthCode(id, saveFileName);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean updateTourCode(String id, String saveFileName) {
        int result = studentMapper.updateTourCode(id, saveFileName);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public List<Student> queryAllStudentsByClassId(String ci) {
        return studentMapper.queryAllStudentsByClassId(ci);
    }

    @Override
    public List<Student> queryAllStudentsByClassId(String[] ids) {
        return studentMapper.getStudentByIdsAndClassId(ids);
    }

    @Override
    public String[] queryStudentsByClassId(String ci) {
        return studentMapper.queryStudentsByClassId(ci);
    }

    @Override
    public Student login(String id_number, String password) {
        return studentMapper.login(id_number, password);
    }

    @Override
    public boolean setStudentPwd(String id, String password) {
        int result = studentMapper.setStudentPwd(id, password);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean setStudentAvatar(String id, String avatar) {
        int result = studentMapper.setAvatar(id, avatar);
        if (result >= 1){
            return true;
        }
        return false;
    }

    @Override
    public boolean punch(String id) {
        int result = studentMapper.punch(id);
        if (result >= 1){
            return true;
        }
        return false;
    }
}
