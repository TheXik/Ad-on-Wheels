import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { campaigns, companies } from '../services/api';

export default function DashboardPage() {
  const { user } = useAuth();
  const [company, setCompany] = useState(null);
  const [campaignList, setCampaignList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    async function load() {
      try {
        const [comp, camps] = await Promise.all([
          companies.getById(user.profileId),
          campaigns.getByCompany(user.profileId),
        ]);
        setCompany(comp);
        setCampaignList(Array.isArray(camps) ? camps : []);
      } catch (err) {
        setError(err.message);
      }
      setLoading(false);
    }
    load();
  }, [user.profileId]);

  if (loading) return <div className="loading">Loading dashboard...</div>;
  if (error) return <div className="error-message">{error}</div>;

  const active = campaignList.filter((c) => c.status === 'RECRUITING' || c.status === 'ONGOING');
  const completed = campaignList.filter((c) => c.status === 'COMPLETED');

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <div>
          <h1>Welcome, {company?.name || 'Company'}</h1>
          <p className="subtitle">{user.email}</p>
        </div>
        <Link to="/campaigns/new" className="btn-primary">
          + New Campaign
        </Link>
      </div>

      <div className="stats-grid">
        <div className="stat-card">
          <span className="stat-value">{campaignList.length}</span>
          <span className="stat-label">Total Campaigns</span>
        </div>
        <div className="stat-card">
          <span className="stat-value">{active.length}</span>
          <span className="stat-label">Active</span>
        </div>
        <div className="stat-card">
          <span className="stat-value">{completed.length}</span>
          <span className="stat-label">Completed</span>
        </div>
      </div>

      <div className="section">
        <div className="section-header">
          <h2>Your Campaigns</h2>
          <button
            className="btn-secondary"
            onClick={async () => {
              try {
                const blob = await campaigns.exportCsv(user.profileId);
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = 'campaigns.csv';
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

        {campaignList.length === 0 ? (
          <div className="empty-state">
            <p>No campaigns yet. Create your first campaign to get started.</p>
          </div>
        ) : (
          <div className="campaign-list">
            {campaignList.map((camp) => (
              <Link to={`/campaigns/${camp.id}`} key={camp.id} className="campaign-card">
                <div className="campaign-card-header">
                  <h3>{camp.name}</h3>
                  <span className={`status-badge status-${camp.status?.toLowerCase()}`}>
                    {camp.status}
                  </span>
                </div>
                <p className="campaign-description">{camp.description}</p>
                <div className="campaign-meta">
                  <span>Budget: €{camp.budget}</span>
                  <span>Max Drivers: {camp.maxDrivers}</span>
                  <span>
                    {new Date(camp.startDate).toLocaleDateString()} – {new Date(camp.endDate).toLocaleDateString()}
                  </span>
                </div>
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
