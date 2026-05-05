import { useEffect, useState } from 'react';
import { messages } from '../services/api';
import { useAuth } from '../context/useAuth';

// Compose a new thread. Subject is required by backend @NotBlank.
// Uses the same compose-overlay/compose-modal styles as CampaignDetailPage
// so both entry points look identical.
export default function ComposeMessageModal({
  isOpen,
  onClose,
  driverId,
  driverName,
  campaignId,
  onSent,
}) {
  const { user } = useAuth();
  const [subject, setSubject] = useState('');
  const [body, setBody] = useState('');
  const [sending, setSending] = useState(false);

  useEffect(() => {
    if (isOpen) {
      setSubject('');
      setBody('');
      setSending(false);
    }
  }, [isOpen]);

  if (!isOpen) return null;

  async function handleSend() {
    if (!subject.trim() || !body.trim() || sending) return;
    setSending(true);
    try {
      await messages.send({
        campaignId,
        senderId: user.profileId,
        senderRole: 'COMPANY',
        recipientId: driverId,
        recipientRole: 'DRIVER',
        subject: subject.trim(),
        body: body.trim(),
      });
      if (onSent) onSent();
      onClose();
    } catch (err) {
      alert(err.message || 'Failed to send message.');
    }
    setSending(false);
  }

  return (
    <div className="compose-overlay" onClick={onClose}>
      <div className="compose-modal" onClick={(e) => e.stopPropagation()}>
        <div className="compose-header">
          <h3>Message {driverName || 'driver'}</h3>
          <button className="compose-close" onClick={onClose}>&times;</button>
        </div>
        <div className="form-group">
          <label>Subject</label>
          <input
            value={subject}
            onChange={(e) => setSubject(e.target.value)}
            placeholder="Enter subject..."
          />
        </div>
        <div className="form-group">
          <label>Message</label>
          <textarea
            value={body}
            onChange={(e) => setBody(e.target.value)}
            placeholder="Write your message..."
            rows={5}
          />
        </div>
        <div className="form-actions">
          <button className="btn-secondary" onClick={onClose} disabled={sending}>
            Cancel
          </button>
          <button
            className="btn-primary"
            onClick={handleSend}
            disabled={!subject.trim() || !body.trim() || sending}
          >
            {sending ? 'Sending...' : 'Send'}
          </button>
        </div>
      </div>
    </div>
  );
}
