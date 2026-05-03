package com.adonwheels.campaignservice.controller;

import com.adonwheels.campaignservice.model.Message;
import com.adonwheels.campaignservice.service.MessageService;
import com.adonwheels.dto.ApiResponse;
import com.adonwheels.dto.validation.NoHtml;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/messages")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Message>> sendMessage(
            @Valid @RequestBody SendMessageRequest request,
            @RequestHeader("X-User-Id") Long callerId,
            @RequestHeader("X-User-Role") String callerRole) {

        if (!callerId.equals(request.senderId) || !callerRole.equals(request.senderRole)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Sender identity mismatch");
        }

        Message msg = messageService.send(
                request.campaignId,
                request.senderId,
                request.senderRole,
                request.recipientId,
                request.recipientRole,
                request.subject,
                request.body
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(msg));
    }

    @GetMapping("/inbox/{recipientId}")
    public ResponseEntity<ApiResponse<List<Message>>> getInbox(
            @PathVariable Long recipientId,
            @RequestHeader("X-User-Id") Long callerId,
            @RequestHeader("X-User-Role") String callerRole) {

        if (!callerId.equals(recipientId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Cannot access another user's inbox");
        }

        return ResponseEntity.ok(ApiResponse.success(
                messageService.getInbox(recipientId, callerRole)));
    }

    @GetMapping("/conversation")
    public ResponseEntity<ApiResponse<List<Message>>> getConversation(
            @RequestParam Long campaignId,
            @RequestParam Long userId1,
            @RequestParam Long userId2,
            @RequestHeader("X-User-Id") Long callerId) {

        if (!callerId.equals(userId1) && !callerId.equals(userId2)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Cannot access this conversation");
        }

        return ResponseEntity.ok(ApiResponse.success(
                messageService.getConversation(campaignId, userId1, userId2)));
    }

    @PatchMapping("/{messageId}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable Long messageId) {
        messageService.markAsRead(messageId);
        return ResponseEntity.ok(ApiResponse.success(null));
    }

    @GetMapping("/unread-count/{recipientId}")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(
            @PathVariable Long recipientId,
            @RequestHeader("X-User-Id") Long callerId,
            @RequestHeader("X-User-Role") String callerRole) {

        if (!callerId.equals(recipientId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Cannot access another user's data");
        }

        return ResponseEntity.ok(ApiResponse.success(
                messageService.getUnreadCount(recipientId, callerRole)));
    }

    public static class SendMessageRequest {
        @NotNull public Long campaignId;
        @NotNull public Long senderId;
        @NotBlank public String senderRole;
        @NotNull public Long recipientId;
        @NotBlank public String recipientRole;
        @NotBlank @NoHtml public String subject;
        @NotBlank @NoHtml public String body;
    }
}
