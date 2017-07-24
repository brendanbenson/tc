package com.textchat;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class SignUpController {
    @RequestMapping("/sign-up")
    public String index(Model model) {
        model.addAttribute("foo", "Hello Handlebars!");
        return "sign-up";
    }
}
