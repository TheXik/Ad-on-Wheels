package com.adonwheels.campaignservice.service;

import com.adonwheels.campaignservice.model.Message;
import com.adonwheels.campaignservice.repository.MessageRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class MessageService {

    private final MessageRepository repository;

    public MessageService(MessageRepository repository) {
        this.repository = repository;
    }

    /** Send a new message */
    @Transactional
    public Message send(Long campaignId, Long senderId, String senderRole,
                        Long recipientId, String subject, String body) {
        Message msg = new Message();
        msg.setCampaignId(campaignId);
        msg.setSenderId(senderId);
        msg.setSenderRole(senderRole);
        msg.setRecipientId(recipientId);
        msg.setSubject(subject);
        msg.setBody(body);
        msg.setCreatedAt(LocalDateTime.now());
        return repository.save(msg);
    }

    /** Get all messages in a user's inbox (newest first) */
    public List<Message> getInbox(Long recipientId) {
        return repository.findByRecipientIdOrderByCreatedAtDesc(recipientId);
    }

    /** Get conversation thread between two users for a campaign */
    public List<Message> getConversation(Long campaignId, Long userId1, Long userId2) {
        return repository
                .findByCampaignIdAndSenderIdAndRecipientIdOrCampaignIdAndSenderIdAndRecipientIdOrderByCreatedAtAsc(
                        campaignId, userId1, userId2,
                        campaignId, userId2, userId1
                );
    }

    /** Mark a message as read */
    @Transactional
    public void markAsRead(Long messageId) {
        Message msg = repository.findById(messageId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Message not found"));
        msg.setRead(true);
        repository.save(msg);
    }

    /** Get unread message count for a user */
    public long getUnreadCount(Long recipientId) {
        return repository.countByRecipientIdAndIsReadFalse(recipientId);
    }
}
