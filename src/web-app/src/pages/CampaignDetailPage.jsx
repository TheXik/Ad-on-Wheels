import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/useAuth';
import { campaigns as campaignsApi, applicationsWithDrivers, messages, campaignStats } from '../services/api';
import CampaignCoverageMap from '../components/CampaignCoverageMap';

export default function CampaignDetailPage() {
  const { id } = useParams();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [campaign, setCampaign] = useState(null);
  const [applications, setApplications] = useState([]);
  const [rideStats, setRideStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [composeTo, setComposeTo] = useState(null);
  const [msgSubject, setMsgSubject] = useState('');
  const [msgBody, setMsgBody] = useState('');
  const [sending, setSending] = useState(false);

  useEffect(() => {
    async function load() {
      try {
        const [camp, apps, stats] = await Promise.all([
          campaignsApi.getById(id),
          applicationsWithDrivers.get(user.profileId),
          campaignStats.getByCompany(user.profileId).catch(() => []),
        ]);
        setCampaign(camp);
        const campaignApps = (Array.isArray(apps) ? apps : []).filter(
          (a) => a.campaignId === parseInt(id)
        );
        setApplications(campaignApps);
        const match = (Array.isArray(stats) ? stats : []).find(
          (s) => s.rideStats?.campaignId === parseInt(id)
        );
        if (match) setRideStats(match.rideStats);
      } catch (err) {
        setError(err.message);
      }
      setLoading(false);
    }
    load();
  }, [id, user.profileId]);

  async function handleApplication(appId, action) {
    try {
      if (action === 'accept') {
        await campaignsApi.acceptApplication(appId);
      } else {
        await campaignsApi.declineApplication(appId);
      }
      setApplications((prev) =>
        prev.map((a) =>
          a.id === appId ? { ...a, status: action === 'accept' ? 'ACCEPTED' : 'DECLINED' } : a
        )
      );
    } catch (err) {
      alert(err.message);
    }
  }

  async function handleSendMessage() {
    if (!composeTo || !msgSubject.trim() || !msgBody.trim()) return;
    setSending(true);
    try {
      await messages.send({
        campaignId: parseInt(id),
        senderId: user.profileId,
        senderRole: 'COMPANY',
        recipientId: composeTo.driver.id,
        recipientRole: 'DRIVER',
        subject: msgSubject,
        body: msgBody,
      });
      setComposeTo(null);
      setMsgSubject('');
      setMsgBody('');
    } catch (err) {
      alert(err.message);
    }
    setSending(false);
  }

  if (loading) return <div className="loading">Loading campaign...</div>;
  if (error) return <div className="error-message">{error}</div>;
  if (!campaign) return <div className="error-message">Campaign not found</div>;

  return (
    <div className="page-container">
      <button className="btn-back" onClick={() => navigate('/dashboard')}>
        ← Back to Dashboard
      </button>

      <div className="campaign-detail-header">
        <div>
          <h1>{campaign.name}</h1>
          <span className={`status-badge status-${campaign.status?.toLowerCase()}`}>
            {campaign.status}
          </span>
        </div>
        <button
          className="btn-secondary"
          onClick={async () => {
            try {
              const blob = await campaignsApi.exportCampaignCsv(campaign.id);
              const url = URL.createObjectURL(blob);
              const a = document.createElement('a');
              a.href = url;
              a.download = `${campaign.name}-stats.csv`;
              a.click();
              URL.revokeObjectURL(url);
            } catch (err) {
              alert(err.message);
            }
          }}
        >
          Export CSV
        </button>
      </div>

      {rideStats && (
        <div className="stats-grid" style={{ marginBottom: '20px' }}>
          <div className="stat-card">
            <span className="stat-value">{rideStats.totalDistanceKm?.toFixed(1)} km</span>
            <span className="stat-label">Km Driven</span>
          </div>
          <div className="stat-card">
            <span className="stat-value">{rideStats.totalRides}</span>
            <span className="stat-label">Rides</span>
          </div>
          <div className="stat-card">
            <span className="stat-value">€{rideStats.totalEarnings?.toFixed(2)}</span>
            <span className="stat-label">Earnings Paid</span>
          </div>
          <div className="stat-card">
            <span className="stat-value">{rideStats.activeDriverCount}</span>
            <span className="stat-label">Active Drivers</span>
          </div>
        </div>
      )}

      <CampaignCoverageMap campaignId={campaign.id} />

      <div className="detail-grid">
        <div className="detail-card">
          <h3>Details</h3>
          <p>{campaign.description}</p>
          <div className="detail-meta">
            <div><strong>Budget:</strong> €{campaign.budget}</div>
            <div><strong>Pay per km:</strong> €{campaign.ratePerKm != null ? Number(campaign.ratePerKm).toFixed(2) : '—'}</div>
            <div><strong>Max Drivers:</strong> {campaign.maxDrivers}</div>
            <div><strong>Start:</strong> {new Date(campaign.startDate).toLocaleDateString()}</div>
            <div><strong>End:</strong> {new Date(campaign.endDate).toLocaleDateString()}</div>
            {campaign.estimatedReach && (
              <div><strong>Est. Reach:</strong> {campaign.estimatedReach.toLocaleString()}</div>
            )}
          </div>
        </div>

        <div className="detail-card">
          <h3>Driver Applications ({applications.length})</h3>
          {applications.length === 0 ? (
            <p className="empty-text">No applications yet.</p>
          ) : (
            <div className="driver-cards">
              {applications.map((app) => (
                <div key={app.id} className="driver-card">
                  <div className="driver-card-header">
                    <div>
                      <span className="driver-name">{app.driver?.name || `Driver #${app.driverId}`}</span>
                      <span className="driver-card-campaign">{app.driver?.email}</span>
                    </div>
                    <span className={`status-badge status-${app.status?.toLowerCase()}`}>
                      {app.status}
                    </span>
                  </div>
                  {app.driver && (
                    <div className="driver-details">
                      <div><strong>Vehicle:</strong> {app.driver.vehicleMake && app.driver.vehicleModel
                        ? `${app.driver.vehicleYear || ''} ${app.driver.vehicleMake} ${app.driver.vehicleModel}`.trim()
                        : 'Not set'}</div>
                      <div><strong>Plate:</strong> {app.driver.vehiclePlate || 'N/A'}</div>
                    </div>
                  )}
                  <div className="application-actions">
                    {app.status === 'APPLIED' && (
                      <>
                        <button
                          className="btn-accept"
                          onClick={() => handleApplication(app.id, 'accept')}
                        >
                          Accept
                        </button>
                        <button
                          className="btn-decline"
                          onClick={() => handleApplication(app.id, 'decline')}
                        >
                          Decline
                        </button>
                      </>
                    )}
                    <button
                      className="btn-secondary"
                      onClick={() => {
                        setComposeTo(app);
                        setMsgSubject('');
                        setMsgBody('');
                      }}
                    >
                      Message
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {composeTo && (
        <div className="compose-overlay" onClick={() => setComposeTo(null)}>
          <div className="compose-modal" onClick={(e) => e.stopPropagation()}>
            <div className="compose-header">
              <h3>Message {composeTo.driver?.name || `Driver #${composeTo.driverId}`}</h3>
              <button className="compose-close" onClick={() => setComposeTo(null)}>&times;</button>
            </div>
            <div className="form-group">
              <label>Subject</label>
              <input
                value={msgSubject}
                onChange={(e) => setMsgSubject(e.target.value)}
                placeholder="Enter subject..."
              />
            </div>
            <div className="form-group">
              <label>Message</label>
              <textarea
                value={msgBody}
                onChange={(e) => setMsgBody(e.target.value)}
                placeholder="Write your message..."
                rows={5}
              />
            </div>
            <div className="form-actions">
              <button className="btn-secondary" onClick={() => setComposeTo(null)}>Cancel</button>
              <button
                className="btn-primary"
                onClick={handleSendMessage}
                disabled={!msgSubject.trim() || !msgBody.trim() || sending}
              >
                {sending ? 'Sending...' : 'Send'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
