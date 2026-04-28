import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/useAuth';
import { campaigns, companies, campaignStats } from '../services/api';

export default function DashboardPage() {
  const { user } = useAuth();
  const [company, setCompany] = useState(null);
  const [campaignList, setCampaignList] = useState([]);
  const [rideStats, setRideStats] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    async function load() {
      try {
        const [comp, camps, stats] = await Promise.all([
          companies.getById(user.profileId),
          campaigns.getByCompany(user.profileId),
          campaignStats.getByCompany(user.profileId).catch(() => []),
        ]);
        setCompany(comp);
        setCampaignList(Array.isArray(camps) ? camps : []);
        const statsMap = {};
        (Array.isArray(stats) ? stats : []).forEach((s) => {
          if (s.rideStats) statsMap[s.rideStats.campaignId] = s.rideStats;
        });
        setRideStats(statsMap);
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
          <span className="stat-value">
            {Object.values(rideStats).reduce((sum, s) => sum + (s.totalDistanceKm || 0), 0).toFixed(1)} km
          </span>
          <span className="stat-label">Total Km Driven</span>
        </div>
        <div className="stat-card">
          <span className="stat-value">
            {Object.values(rideStats).reduce((sum, s) => sum + (s.totalRides || 0), 0)}
          </span>
          <span className="stat-label">Total Rides</span>
        </div>
      </div>

      <div className="section">
        <div className="section-header">
          <h2>Your Campaigns</h2>
          <button
            className="btn-secondary"
            onClick={async () => {
              try {
                const blob = await campaignStats.exportCsv(user.profileId);
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
                {rideStats[camp.id] && (
                  <div className="campaign-meta" style={{ marginTop: '6px' }}>
                    <span>{rideStats[camp.id].totalDistanceKm?.toFixed(1)} km driven</span>
                    <span>{rideStats[camp.id].totalRides} rides</span>
                    <span>{rideStats[camp.id].activeDriverCount} active drivers</span>
                  </div>
                )}
              </Link>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
