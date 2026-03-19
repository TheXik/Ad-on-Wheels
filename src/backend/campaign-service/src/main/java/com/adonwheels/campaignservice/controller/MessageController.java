package com.adonwheels.campaignservice.controller;

import com.adonwheels.campaignservice.model.Message;
import com.adonwheels.campaignservice.service.MessageService;
import dto.ApiResponse;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * UC005 – Messaging endpoints for driver ↔ company communication.
 */
@RestController
@RequestMapping("/messages")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    /** Send a new message */
    @PostMapping
    public ResponseEntity<ApiResponse<Message>> sendMessage(@Valid @RequestBody SendMessageRequest request) {
        Message msg = messageService.send(
                request.campaignId,
                request.senderId,
                request.senderRole,
                request.recipientId,
                request.subject,
                request.body
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(msg));
    }

    /** Get inbox for a user (all received messages, newest first) */
    @GetMapping("/inbox/{recipientId}")
    public ResponseEntity<ApiResponse<List<Message>>> getInbox(@PathVariable Long recipientId) {
        return ResponseEntity.ok(ApiResponse.success(messageService.getInbox(recipientId)));
    }

    /** Get conversation thread between two users for a campaign */
    @GetMapping("/conversation")
    public ResponseEntity<ApiResponse<List<Message>>> getConversation(
            @RequestParam Long campaignId,
            @RequestParam Long userId1,
            @RequestParam Long userId2) {
        return ResponseEntity.ok(ApiResponse.success(
                messageService.getConversation(campaignId, userId1, userId2)));
    }

    /** Mark a message as read */
    @PatchMapping("/{messageId}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long messageId) {
        messageService.markAsRead(messageId);
        return ResponseEntity.ok().build();
    }

    /** Get unread message count */
    @GetMapping("/unread-count/{recipientId}")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(@PathVariable Long recipientId) {
        return ResponseEntity.ok(ApiResponse.success(messageService.getUnreadCount(recipientId)));
    }

    /** Request body for sending a message */
    public static class SendMessageRequest {
        @NotNull public Long campaignId;
        @NotNull public Long senderId;
        @NotBlank public String senderRole;
        @NotNull public Long recipientId;
        @NotBlank public String subject;
        @NotBlank public String body;
    }
}
