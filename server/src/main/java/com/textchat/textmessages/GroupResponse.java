package com.textchat.textmessages;

import com.textchat.persistence.groups.Group;

public class GroupResponse {
    private Long id;
    private String label;

    public GroupResponse(Long id, String label) {
        this.id = id;
        this.label = label;
    }

    public GroupResponse(Group group) {
        this(
                group.getId(),
                group.getLabel()
        );
    }

    public Long getId() {
        return id;
    }

    public String getLabel() {
        return label;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        GroupResponse that = (GroupResponse) o;

        return label != null ? label.equals(that.label) : that.label == null;
    }

    @Override
    public int hashCode() {
        return label != null ? label.hashCode() : 0;
    }
}
