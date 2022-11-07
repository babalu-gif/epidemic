import com.my.entity.Admin;
import com.my.mapper.AdminMapper;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

public class test {

    @Autowired
    private AdminMapper adminMapper;

    /*@Test
    public void testGetAllAdmin(){

        System.out.println("========");
        System.out.println("========");
        System.out.println("========");

        List<Admin> adminList = adminMapper.getAllAdmins();
        for (Admin admin : adminList){
            System.out.println(admin);
        }
    }*/
}
