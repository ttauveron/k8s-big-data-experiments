package com.pfe.k8stestapp.demo.userdb;

import com.pfe.k8stestapp.demo.userdb.MainController;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PropertiesLoaderUtils;

import java.util.Properties;

@SpringBootApplication
public class UserApplication {

    public static void main(String[] args) {

        Resource resource = new ClassPathResource("/application.properties");
        Properties prop = null;

        try {
            prop = PropertiesLoaderUtils.loadProperties(resource);
        } catch (Exception e){
            e.printStackTrace();
        }

        prop.setProperty("server.port", prop.getProperty("k8stestapp.userdb.port"));

        new SpringApplicationBuilder()
                .sources(UserApplication.class)
                .properties(prop)
                .run(args);
    }
}
