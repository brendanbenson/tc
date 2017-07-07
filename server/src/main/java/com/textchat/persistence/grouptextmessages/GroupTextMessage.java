package com.textchat.persistence.grouptextmessages;

import com.textchat.persistence.groups.Group;

import javax.persistence.*;

@Entity
@Table(name = "group_text_messages")
public class GroupTextMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String body;

    @ManyToOne
    private Group group;

    public GroupTextMessage() {
    }

    public GroupTextMessage(String body, Group group) {
        this.body = body;
        this.group = group;
    }

    public Long getId() {

        return id;
    }

    public String getBody() {
        return body;
    }

    public Group getGroup() {
        return group;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        GroupTextMessage that = (GroupTextMessage) o;

        if (id != null ? !id.equals(that.id) : that.id != null) return false;
        if (body != null ? !body.equals(that.body) : that.body != null) return false;
        return group != null ? group.equals(that.group) : that.group == null;
    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (body != null ? body.hashCode() : 0);
        result = 31 * result + (group != null ? group.hashCode() : 0);
        return result;
    }
}
