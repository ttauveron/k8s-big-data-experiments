package com.pfe.k8stestapp.demo.userdb;

import com.pfe.k8stestapp.demo.userdb.MainController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.core.env.Environment;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PropertiesLoaderUtils;

import javax.swing.*;
import java.util.Properties;

@SpringBootApplication
public class UserApplication {

    @Autowired
    private Environment environment;

    public static void main(String[] args) {
        SpringApplication.run(UserApplication.class, args);
    }
}
