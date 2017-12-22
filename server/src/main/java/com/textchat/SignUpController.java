package com.textchat;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
public class SignUpController {
    @RequestMapping(value = "/sign-up", method = RequestMethod.GET)
    public String index(Model model) {
        return "sign-up";
    }
}
