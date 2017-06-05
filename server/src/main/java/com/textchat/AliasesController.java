package com.textchat;

import com.textchat.persistence.aliases.AliasRepository;
import com.textchat.persistence.aliases.AliasRow;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AliasesController {
    private AliasRepository aliasRepository;

    @Autowired
    public AliasesController(AliasRepository aliasRepository) {
        this.aliasRepository = aliasRepository;
    }

    @PostMapping("/aliases")
    public void create(@RequestBody AliasRequest aliasRequest) {
        aliasRepository.save(
                new AliasRow(aliasRequest.getPhoneNumber(), aliasRequest.getLabel())
        );
    }

    private static class AliasRequest {
        private String phoneNumber;
        private String label;

        public String getPhoneNumber() {
            return phoneNumber;
        }

        public String getLabel() {
            return label;
        }
    }
}
