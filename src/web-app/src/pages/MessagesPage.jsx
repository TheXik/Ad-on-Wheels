import { useCallback, useEffect, useRef, useState } from 'react';
import { useAuth } from '../context/useAuth';
import { messages, drivers, companies, campaigns as campaignsApi } from '../services/api';

// Backend sends LocalDateTime without timezone marker. JVM in Docker is UTC.
// Append Z and format in Europe/Prague.
const PRAGUE_TZ = 'Europe/Prague';

function asUTC(iso) {
  if (!iso) return null;
  const withZ = /[zZ]|[+-]\d{2}:?\d{2}$/.test(iso) ? iso : iso + 'Z';
  const d = new Date(withZ);
  return isNaN(d.getTime()) ? null : d;
}

function formatPragueDateTime(iso) {
  const d = asUTC(iso);
  if (!d) return '';
  return d.toLocaleString('en-GB', {
    timeZone: PRAGUE_TZ,
    dateStyle: 'short',
    timeStyle: 'short',
  });
}

function formatPragueDate(iso) {
  const d = asUTC(iso);
  if (!d) return '';
  return d.toLocaleDateString('en-GB', { timeZone: PRAGUE_TZ });
}

// Thread key. Inbox seeds the list. Conversation endpoint backs the stream.
export default function MessagesPage() {
  const { user } = useAuth();
  const [threads, setThreads] = useState([]);
  const [selectedKey, setSelectedKey] = useState(null);
  const [conversation, setConversation] = useState([]);
  const [replyText, setReplyText] = useState('');
  const [loading, setLoading] = useState(true);
  const [convLoading, setConvLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const pollRef = useRef(null);
  const nameCacheRef = useRef({});
  // Campaign id to name. Lazy. Missing entries fall back to "Campaign #X".
  const campaignCacheRef = useRef({});
  const streamRef = useRef(null);
  const selectedKeyRef = useRef(null);
  selectedKeyRef.current = selectedKey;
  // Ref-mirror so the polling effect can read threads without depending on it.
  const threadsRef = useRef([]);
  threadsRef.current = threads;

  // Both senderId and senderRole must match. Driver and company id spaces are independent.
  const isMine = useCallback(
    (m) => m.senderId === user.profileId && m.senderRole === user.role,
    [user.profileId, user.role]
  );
  const otherIdOf = useCallback(
    (m) => (isMine(m) ? m.recipientId : m.senderId),
    [isMine]
  );
  const otherRoleOf = useCallback(
    (m) => (isMine(m) ? m.recipientRole : m.senderRole),
    [isMine]
  );

  const buildThreads = useCallback(
    async (msgs) => {
      const driverIds = [
        ...new Set(
          msgs
            .filter((m) => otherRoleOf(m) === 'DRIVER')
            .map((m) => otherIdOf(m))
        ),
      ];
      const companyIds = [
        ...new Set(
          msgs
            .filter((m) => otherRoleOf(m) === 'COMPANY')
            .map((m) => otherIdOf(m))
        ),
      ];
      const missingDrivers = driverIds.filter((id) => !nameCacheRef.current[`DRIVER-${id}`]);
      const missingCompanies = companyIds.filter((id) => !nameCacheRef.current[`COMPANY-${id}`]);
      await Promise.all([
        ...missingDrivers.map(async (did) => {
          try {
            const d = await drivers.getById(did);
            if (d?.name) nameCacheRef.current[`DRIVER-${did}`] = d.name;
          } catch { /* retry on next poll */ }
        }),
        ...missingCompanies.map(async (cid) => {
          try {
            const c = await companies.getById(cid);
            if (c?.name) nameCacheRef.current[`COMPANY-${cid}`] = c.name;
          } catch { /* retry on next poll */ }
        }),
      ]);

      // Resolve campaign names (used in both thread sidebar subject and detail header)
      const campaignIds = [...new Set(msgs.map((m) => m.campaignId))];
      const missingCampaigns = campaignIds.filter((id) => !campaignCacheRef.current[id]);
      await Promise.all(
        missingCampaigns.map(async (cid) => {
          try {
            const c = await campaignsApi.getById(cid);
            if (c?.name) campaignCacheRef.current[cid] = c.name;
          } catch { /* fallback to "Campaign #X" */ }
        })
      );

      const map = new Map();
      for (const m of msgs) {
        const otherId = otherIdOf(m);
        const otherRole = otherRoleOf(m);
        const key = `${m.campaignId}-${otherRole}-${otherId}`;
        const existing = map.get(key);
        if (
          !existing ||
          new Date(m.createdAt) > new Date(existing.latest.createdAt)
        ) {
          const fallback = otherRole === 'DRIVER' ? 'Driver' : 'Company';
          map.set(key, {
            key,
            campaignId: m.campaignId,
            campaignName: campaignCacheRef.current[m.campaignId] || 'Campaign',
            otherId,
            otherRole,
            otherName: nameCacheRef.current[`${otherRole}-${otherId}`] || fallback,
            latest: m,
            unreadCount: 0,
            subject: m.subject,
          });
        }
      }
      // Unread = incoming-and-unread; my own outgoing never counts.
      for (const m of msgs) {
        if (!m.isRead && !isMine(m)) {
          const key = `${m.campaignId}-${otherRoleOf(m)}-${otherIdOf(m)}`;
          const t = map.get(key);
          if (t) t.unreadCount += 1;
        }
      }
      return [...map.values()].sort(
        (a, b) => new Date(b.latest.createdAt) - new Date(a.latest.createdAt)
      );
    },
    [otherIdOf, otherRoleOf, isMine]
  );

  const loadThreads = useCallback(async () => {
    try {
      const data = await messages.getAllForUser(user.profileId);
      const msgs = Array.isArray(data) ? data : [];
      const built = await buildThreads(msgs);
      setThreads(built);
    } catch {
      setThreads([]);
    }
  }, [user.profileId, buildThreads]);

  const loadConversation = useCallback(
    async (thread, { markRead = true } = {}) => {
      if (!thread) return;
      setConvLoading(true);
      try {
        const data = await messages.getConversation(
          thread.campaignId,
          user.profileId,
          thread.otherId
        );
        const conv = Array.isArray(data) ? data : [];
        conv.sort(
          (a, b) => new Date(a.createdAt) - new Date(b.createdAt)
        );
        setConversation(conv);

        if (markRead) {
          const unread = conv.filter(
            (m) => !m.isRead && m.recipientId === user.profileId
          );
          if (unread.length > 0) {
            await Promise.all(
              unread.map((m) =>
                messages.markRead(m.id).catch(() => {})
              )
            );
            await loadThreads();
          }
        }
      } catch {
        setConversation([]);
      }
      setConvLoading(false);
    },
    [user.profileId, loadThreads]
  );

  // Initial load
  useEffect(() => {
    (async () => {
      await loadThreads();
      setLoading(false);
    })();
  }, [loadThreads]);

  // 15s poll. Reads threads via threadsRef to keep the interval mounted once.
  useEffect(() => {
    pollRef.current = setInterval(() => {
      loadThreads();
      const k = selectedKeyRef.current;
      if (k) {
        const t = threadsRef.current.find((x) => x.key === k);
        if (t) loadConversation(t, { markRead: false });
      }
    }, 15000);
    function onVisible() {
      if (document.visibilityState === 'visible') {
        loadThreads();
        const k = selectedKeyRef.current;
        if (k) {
          const t = threadsRef.current.find((x) => x.key === k);
          if (t) loadConversation(t, { markRead: false });
        }
      }
    }
    document.addEventListener('visibilitychange', onVisible);
    window.addEventListener('focus', onVisible);
    return () => {
      clearInterval(pollRef.current);
      document.removeEventListener('visibilitychange', onVisible);
      window.removeEventListener('focus', onVisible);
    };
  }, [loadThreads, loadConversation]);

  // Auto-scroll to the bottom whenever conversation grows.
  useEffect(() => {
    if (streamRef.current) {
      streamRef.current.scrollTop = streamRef.current.scrollHeight;
    }
  }, [conversation, selectedKey]);

  function selectThread(t) {
    setSelectedKey(t.key);
    setReplyText('');
    setConversation([]);
    loadConversation(t);
  }

  async function handleReply() {
    const thread = threads.find((t) => t.key === selectedKey);
    if (!replyText.trim() || !thread) return;
    setSending(true);
    try {
      const baseSubject = thread.subject || 'Conversation';
      const subject = baseSubject.startsWith('Re:')
        ? baseSubject
        : `Re: ${baseSubject}`;
      await messages.send({
        campaignId: thread.campaignId,
        senderId: user.profileId,
        senderRole: user.role,
        recipientId: thread.otherId,
        recipientRole: thread.otherRole,
        subject,
        body: replyText.trim(),
      });
      setReplyText('');
      await loadConversation(thread, { markRead: false });
      await loadThreads();
    } catch (err) {
      alert(err.message);
    }
    setSending(false);
  }

  if (loading) return <div className="loading">Loading messages...</div>;

  const activeThread = threads.find((t) => t.key === selectedKey) || null;

  return (
    <div className="messages-page">
      <h1>Messages</h1>
      <div className="messages-layout">
        <div className="messages-sidebar">
          {threads.length === 0 ? (
            <div className="empty-text">No messages yet.</div>
          ) : (
            threads.map((t) => (
              <div
                key={t.key}
                className={`message-preview ${
                  selectedKey === t.key ? 'active' : ''
                } ${t.unreadCount > 0 ? 'unread' : ''}`}
                onClick={() => selectThread(t)}
              >
                <div className="message-preview-header">
                  <span className="sender">
                    {t.otherName}
                    {t.unreadCount > 0 && (
                      <span className="unread-badge">
                        {' '}
                        ({t.unreadCount})
                      </span>
                    )}
                  </span>
                  <span className="time">
                    {formatPragueDate(t.latest.createdAt)}
                  </span>
                </div>
                <div className="message-subject">
                  {t.campaignName}
                  {t.subject ? ` · ${t.subject}` : ''}
                </div>
                <div className="message-snippet">
                  {isMine(t.latest) ? 'You: ' : ''}
                  {t.latest.body?.substring(0, 60)}
                  {t.latest.body?.length > 60 ? '...' : ''}
                </div>
              </div>
            ))
          )}
        </div>

        <div className="message-detail">
          {activeThread ? (
            <>
              <div className="message-detail-header">
                <h2>{activeThread.otherName}</h2>
                <span className="meta">
                  {activeThread.subject ? `${activeThread.subject} · ` : ''}
                  {activeThread.campaignName}
                </span>
              </div>
              <div className="conversation-stream" ref={streamRef}>
                {convLoading && conversation.length === 0 ? (
                  <div className="empty-state">Loading conversation...</div>
                ) : conversation.length === 0 ? (
                  <div className="empty-state">
                    <p>No messages yet. Send the first one below.</p>
                  </div>
                ) : (
                  conversation.map((m) => {
                    const mine = isMine(m);
                    return (
                      <div
                        key={m.id}
                        className={`chat-bubble ${mine ? 'mine' : 'theirs'}`}
                      >
                        <div className="chat-bubble-body">{m.body}</div>
                        <div className="chat-bubble-meta">
                          {formatPragueDateTime(m.createdAt)}
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
              <div className="reply-section">
                <textarea
                  value={replyText}
                  onChange={(e) => setReplyText(e.target.value)}
                  placeholder="Type your message..."
                  rows={3}
                  onKeyDown={(e) => {
                    if (
                      (e.metaKey || e.ctrlKey) &&
                      e.key === 'Enter' &&
                      !sending &&
                      replyText.trim()
                    ) {
                      e.preventDefault();
                      handleReply();
                    }
                  }}
                />
                <button
                  className="btn-primary"
                  onClick={handleReply}
                  disabled={!replyText.trim() || sending}
                >
                  {sending ? 'Sending...' : 'Send'}
                </button>
              </div>
            </>
          ) : (
            <div className="empty-state">
              <p>Select a conversation to read</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
