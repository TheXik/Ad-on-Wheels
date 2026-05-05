package com.adonwheels.campaignservice.repository;

import com.adonwheels.campaignservice.model.Message;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {

    List<Message> findByRecipientIdAndRecipientRoleOrderByCreatedAtDesc(Long recipientId, String recipientRole);

    // All messages a user is part of (sent + received).
    List<Message> findByRecipientIdAndRecipientRoleOrSenderIdAndSenderRoleOrderByCreatedAtDesc(
            Long recipientId, String recipientRole,
            Long senderId, String senderRole);

    List<Message> findByCampaignIdAndSenderIdAndRecipientIdOrCampaignIdAndSenderIdAndRecipientIdOrderByCreatedAtAsc(
            Long campaignId1, Long senderId1, Long recipientId1,
            Long campaignId2, Long senderId2, Long recipientId2
    );

    long countByRecipientIdAndRecipientRoleAndIsReadFalse(Long recipientId, String recipientRole);
}
