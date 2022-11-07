package com.my.service;

import com.my.entity.ReturnObject;
import com.my.entity.Student;

import java.util.List;

public interface StudentService {
    ReturnObject saveStudent(Student student);

    Student queryStudentById(String id);

    boolean deleteStudentByIds(String[] ids);

    boolean deleteStudentById(String id);

    ReturnObject updateStudent(Student student);

    List<Student> queryAllStudents();

    List<Student> getStudentByIds(String[] ids);

    List<Student> getStudents(Student student);

    List<Student> getNotClockStudents();

    List<Student> getNotClockStudentsByStudentIds(String[] studentIds);

    List<Student> getNotTourStudents();

    List<Student> getNotTourStudentsByStudentIds(String[] studentIds);

    List<Student> getNotHealthStudents();

    List<Student> getNotHealthStudentsByStudentIds(String[] studentIds);

    ReturnObject saveStudents(List<Student> studentList);

    boolean resetPassword(Student student);

    boolean resetHealthAndTourCode(Student student);

    boolean resetPunch(Student student);

    boolean updateHealthCode(String id, String saveFileName);

    boolean updateTourCode(String id, String saveFileName);

    List<Student> queryAllStudentsByClassId(String ci);

    List<Student> queryAllStudentsByClassId(String[] ids);

    String[] queryStudentsByClassId(String ci);

    Student login(String id_number, String password);

    boolean setStudentPwd(String id, String password);

    boolean setStudentAvatar(String id, String avatar);

    boolean punch(String id);

}
