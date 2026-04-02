import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { messages, drivers } from '../services/api';

export default function MessagesPage() {
  const { user } = useAuth();
  const [inbox, setInbox] = useState([]);
  const [selected, setSelected] = useState(null);
  const [replyText, setReplyText] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [driverNames, setDriverNames] = useState({});

  useEffect(() => {
    async function load() {
      try {
        const data = await messages.getInbox(user.profileId);
        const msgs = Array.isArray(data) ? data : [];
        setInbox(msgs);

        const driverIds = [...new Set(
          msgs.filter((m) => m.senderRole === 'DRIVER').map((m) => m.senderId)
        )];
        const names = {};
        await Promise.all(
          driverIds.map(async (did) => {
            try {
              const d = await drivers.getById(did);
              names[did] = d.name;
            } catch {
              // keep as fallback
            }
          })
        );
        setDriverNames(names);
      } catch {
        setInbox([]);
      }
      setLoading(false);
    }
    load();
  }, [user.profileId]);

  async function handleReply() {
    if (!replyText.trim() || !selected) return;
    setSending(true);
    try {
      await messages.send({
        campaignId: selected.campaignId,
        senderId: user.profileId,
        senderRole: 'COMPANY',
        recipientId: selected.senderId,
        subject: `Re: ${selected.subject}`,
        body: replyText,
      });
      setReplyText('');
      const data = await messages.getInbox(user.profileId);
      setInbox(Array.isArray(data) ? data : []);
    } catch (err) {
      alert(err.message);
    }
    setSending(false);
  }

  async function selectMessage(msg) {
    setSelected(msg);
    setReplyText('');
    if (!msg.read) {
      try {
        await messages.markRead(msg.id);
        setInbox((prev) => prev.map((m) => (m.id === msg.id ? { ...m, read: true } : m)));
      } catch {
        // non-critical
      }
    }
  }

  if (loading) return <div className="loading">Loading messages...</div>;

  return (
    <div className="messages-page">
      <h1>Messages</h1>
      <div className="messages-layout">
        <div className="messages-sidebar">
          {inbox.length === 0 ? (
            <div className="empty-text">No messages yet.</div>
          ) : (
            inbox.map((msg) => (
              <div
                key={msg.id}
                className={`message-preview ${selected?.id === msg.id ? 'active' : ''} ${!msg.read ? 'unread' : ''}`}
                onClick={() => selectMessage(msg)}
              >
                <div className="message-preview-header">
                  <span className="sender">{driverNames[msg.senderId] || `Driver #${msg.senderId}`}</span>
                  <span className="time">
                    {new Date(msg.createdAt).toLocaleDateString()}
                  </span>
                </div>
                <div className="message-subject">{msg.subject}</div>
                <div className="message-snippet">
                  {msg.body?.substring(0, 60)}
                  {msg.body?.length > 60 ? '...' : ''}
                </div>
              </div>
            ))
          )}
        </div>

        <div className="message-detail">
          {selected ? (
            <>
              <div className="message-detail-header">
                <h2>{selected.subject}</h2>
                <span className="meta">
                  From: {driverNames[selected.senderId] || `Driver #${selected.senderId}`} | Campaign #{selected.campaignId} |{' '}
                  {new Date(selected.createdAt).toLocaleString()}
                </span>
              </div>
              <div className="message-body">{selected.body}</div>
              <div className="reply-section">
                <textarea
                  value={replyText}
                  onChange={(e) => setReplyText(e.target.value)}
                  placeholder="Type your reply..."
                  rows={4}
                />
                <button
                  className="btn-primary"
                  onClick={handleReply}
                  disabled={!replyText.trim() || sending}
                >
                  {sending ? 'Sending...' : 'Send Reply'}
                </button>
              </div>
            </>
          ) : (
            <div className="empty-state">
              <p>Select a message to read</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
