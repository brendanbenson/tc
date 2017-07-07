package com.textchat.textmessages;

import com.textchat.persistence.grouptextmessages.GroupTextMessage;

public class GroupTextMessageResponse {
    private Long id;
    private String body;
    private GroupResponse group;

    public GroupTextMessageResponse() {
    }

    public GroupTextMessageResponse(Long id, String body, GroupResponse group) {
        this.id = id;
        this.body = body;
        this.group = group;
    }

    public GroupTextMessageResponse(GroupTextMessage savedMessage) {
        this(
                savedMessage.getId(),
                savedMessage.getBody(),
                new GroupResponse(savedMessage.getGroup())
        );
    }

    public Long getId() {
        return id;
    }

    public String getBody() {
        return body;
    }

    public GroupResponse getGroup() {
        return group;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        GroupTextMessageResponse that = (GroupTextMessageResponse) o;

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
