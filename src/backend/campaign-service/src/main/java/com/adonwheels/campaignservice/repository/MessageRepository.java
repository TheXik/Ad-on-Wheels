package com.adonwheels.campaignservice.repository;

import com.adonwheels.campaignservice.model.Message;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {

    /** All messages received by a user, newest first */
    List<Message> findByRecipientIdOrderByCreatedAtDesc(Long recipientId);

    /** All messages in a conversation (campaign + both parties) */
    List<Message> findByCampaignIdAndSenderIdAndRecipientIdOrCampaignIdAndSenderIdAndRecipientIdOrderByCreatedAtAsc(
            Long campaignId1, Long senderId1, Long recipientId1,
            Long campaignId2, Long senderId2, Long recipientId2
    );

    /** Count unread messages for a recipient */
    long countByRecipientIdAndIsReadFalse(Long recipientId);

    /** All messages for a given campaign */
    List<Message> findByCampaignIdOrderByCreatedAtDesc(Long campaignId);
}
