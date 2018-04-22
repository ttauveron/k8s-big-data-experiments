package com.pfe.k8stestapp.demo.greeter;

import java.util.Properties;
import java.util.concurrent.atomic.AtomicLong;

import com.pfe.k8stestapp.demo.greeter.Greeting;
import com.pfe.k8stestapp.demo.userdb.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PropertiesLoaderUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class GreetingController {

    private static final String template = "Hello, %s!";
    private final AtomicLong counter = new AtomicLong();

    @Value("${k8stestapp.userdb.url}")
    private String userDBUrl;
    @Value("${k8stestapp.userdb.port}")
    private String userDBPort;

    @RequestMapping("/greeting")
    public Greeting greeting(@RequestParam(value="name", defaultValue="World") String name) {

        if(!name.equals("World"))
        {
            RestTemplate restTemplate = new RestTemplate();
            User user = restTemplate.getForObject(getUserDbUrl(name), User.class);

            if(user.getName() != null)
                return new Greeting(counter.incrementAndGet(), String.format(template, name) + ": " + user.getEmail());
            else
                return new Greeting(counter.incrementAndGet(), String.format(template, name));
        }
        else
            return new Greeting(counter.incrementAndGet(), String.format(template, name));
    }


    @RequestMapping("/health")
    public ResponseEntity<GreetingController> health()
    {
        RestTemplate restTemplate = new RestTemplate();
        User user = restTemplate.getForObject(getUserDbUrl("World"), User.class);

        if(user == null)
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(null);
        else
            return ResponseEntity.status(HttpStatus.OK).body(null);
    }

    @RequestMapping("/ping")
    public ResponseEntity<GreetingController> ping()
    {
        return ResponseEntity.ok(null);
    }

    private String getUserDbUrl(String name)
    {
        return userDBUrl + ":" + userDBPort + "/demo/get?name=" + name;
    }
}