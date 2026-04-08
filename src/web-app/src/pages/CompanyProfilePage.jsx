import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { companies, applicationsWithDrivers, campaigns } from '../services/api';

export default function CompanyProfilePage() {
  const { user } = useAuth();
  const [company, setCompany] = useState(null);
  const [applications, setApplications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    async function load() {
      try {
        const [comp, apps] = await Promise.all([
          companies.getById(user.profileId),
          applicationsWithDrivers.get(user.profileId),
        ]);
        setCompany(comp);
        setApplications(Array.isArray(apps) ? apps : []);
      } catch (err) {
        setError(err.message);
      }
      setLoading(false);
    }
    load();
  }, [user.profileId]);

  async function handleApplication(appId, action) {
    try {
      if (action === 'accept') {
        await campaigns.acceptApplication(appId);
      } else {
        await campaigns.declineApplication(appId);
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

  if (loading) return <div className="loading">Loading profile...</div>;
  if (error) return <div className="error-message">{error}</div>;

  const applied = applications.filter((a) => a.status === 'APPLIED');
  const accepted = applications.filter((a) => a.status === 'ACCEPTED');
  const declined = applications.filter((a) => a.status === 'DECLINED');

  return (
    <div className="profile-page">
      <div className="dashboard-header">
        <div>
          <h1>{company?.name || 'Company'}</h1>
          <p className="subtitle">{company?.email || user.email}</p>
        </div>
      </div>

      <div className="stats-grid">
        <div className="stat-card">
          <span className="stat-value">{applications.length}</span>
          <span className="stat-label">Total Applications</span>
        </div>
        <div className="stat-card">
          <span className="stat-value">{applied.length}</span>
          <span className="stat-label">Applied</span>
        </div>
        <div className="stat-card">
          <span className="stat-value">{accepted.length}</span>
          <span className="stat-label">Accepted</span>
        </div>
        <div className="stat-card">
          <span className="stat-value">{declined.length}</span>
          <span className="stat-label">Declined</span>
        </div>
      </div>

      <div className="section">
        <div className="section-header">
          <h2>Driver Applications</h2>
        </div>

        {applications.length === 0 ? (
          <div className="empty-state">
            <p>No applications yet.</p>
          </div>
        ) : (
          <div className="driver-cards">
            {applications.map((app) => (
              <div key={app.id} className="driver-card">
                <div className="driver-card-header">
                  <div>
                    <span className="driver-name">{app.driver?.name || `Driver #${app.id}`}</span>
                    <span className="driver-card-campaign">{app.campaignName}</span>
                  </div>
                  <span className={`status-badge status-${app.status?.toLowerCase()}`}>
                    {app.status}
                  </span>
                </div>
                <div className="driver-details">
                  <div><strong>Email:</strong> {app.driver?.email || 'N/A'}</div>
                  <div><strong>Vehicle:</strong> {[app.driver?.vehicleYear, app.driver?.vehicleMake, app.driver?.vehicleModel].filter(Boolean).join(' ') || 'N/A'}</div>
                  <div><strong>Color:</strong> {app.driver?.vehicleColor || 'N/A'}</div>
                  <div><strong>Plate:</strong> {app.driver?.vehiclePlate || 'N/A'}</div>
                  <div><strong>Verified:</strong> {app.driver?.vehicleVerified ? 'Yes' : 'No'}</div>
                  <div><strong>Rating:</strong> {app.driver?.rating ?? 'N/A'}</div>
                  <div><strong>Member Since:</strong> {app.driver?.memberSince ? new Date(app.driver.memberSince).toLocaleDateString() : 'N/A'}</div>
                </div>
                {app.status === 'APPLIED' && (
                  <div className="application-actions">
                    <button className="btn-accept" onClick={() => handleApplication(app.id, 'accept')}>
                      Accept
                    </button>
                    <button className="btn-decline" onClick={() => handleApplication(app.id, 'decline')}>
                      Decline
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
