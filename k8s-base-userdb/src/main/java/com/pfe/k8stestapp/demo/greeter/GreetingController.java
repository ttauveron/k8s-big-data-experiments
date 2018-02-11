package com.pfe.k8stestapp.demo.greeter;

import java.util.Properties;
import java.util.concurrent.atomic.AtomicLong;

import com.pfe.k8stestapp.demo.greeter.Greeting;
import com.pfe.k8stestapp.demo.userdb.User;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PropertiesLoaderUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class GreetingController {

    private static final String template = "Hello, %s!";
    private final AtomicLong counter = new AtomicLong();

    @RequestMapping("/greeting")
    public Greeting greeting(@RequestParam(value="name", defaultValue="World") String name) {

        if(!name.equals("World"))
        {
            RestTemplate restTemplate = new RestTemplate();
            Resource resource = new ClassPathResource("/application.properties");
            Properties prop = null;

            try {
                prop = PropertiesLoaderUtils.loadProperties(resource);
            } catch (Exception e){
                e.printStackTrace();
            }

            User user = restTemplate.getForObject(prop.getProperty("k8stestapp.userdb.url") + ":" + prop.getProperty("k8stestapp.userdb.port") + "/demo/get?name=" + name, User.class);


            if(user.getName() != null)
                return new Greeting(counter.incrementAndGet(), String.format(template, name) + ": " + user.getEmail());
            else
                return new Greeting(counter.incrementAndGet(), String.format(template, name));
        }
        else
            return new Greeting(counter.incrementAndGet(), String.format(template, name));
    }
}