import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { campaigns } from '../services/api';

export default function CreateCampaignPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({
    name: '',
    description: '',
    startDate: '',
    endDate: '',
    budget: '',
    maxDrivers: '',
    estimatedReach: '',
  });
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  function update(field, value) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setIsSubmitting(true);
    try {
      await campaigns.create({
        companyId: user.profileId,
        name: form.name,
        description: form.description,
        startDate: form.startDate,
        endDate: form.endDate,
        budget: parseFloat(form.budget),
        maxDrivers: parseInt(form.maxDrivers),
        estimatedReach: form.estimatedReach ? parseInt(form.estimatedReach) : null,
        status: 'RECRUITING',
      });
      navigate('/dashboard');
    } catch (err) {
      setError(err.message);
    }
    setIsSubmitting(false);
  }

  return (
    <div className="page-container">
      <h1>Create Campaign</h1>
      <form onSubmit={handleSubmit} className="form-card">
        <div className="form-group">
          <label>Campaign Name</label>
          <input value={form.name} onChange={(e) => update('name', e.target.value)} required />
        </div>

        <div className="form-group">
          <label>Description</label>
          <textarea
            value={form.description}
            onChange={(e) => update('description', e.target.value)}
            rows={4}
            placeholder="Describe what drivers should know..."
            required
          />
        </div>

        <div className="form-row">
          <div className="form-group">
            <label>Start Date</label>
            <input type="date" value={form.startDate} onChange={(e) => update('startDate', e.target.value)} required />
          </div>
          <div className="form-group">
            <label>End Date</label>
            <input type="date" value={form.endDate} onChange={(e) => update('endDate', e.target.value)} required />
          </div>
        </div>

        <div className="form-row">
          <div className="form-group">
            <label>Total Budget (€)</label>
            <input type="number" step="0.01" value={form.budget} onChange={(e) => update('budget', e.target.value)} required />
          </div>
          <div className="form-group">
            <label>Max Drivers</label>
            <input type="number" value={form.maxDrivers} onChange={(e) => update('maxDrivers', e.target.value)} required />
          </div>
          <div className="form-group">
            <label>Estimated Reach (optional)</label>
            <input type="number" value={form.estimatedReach} onChange={(e) => update('estimatedReach', e.target.value)} />
          </div>
        </div>

        {error && <div className="error-message">{error}</div>}

        <div className="form-actions">
          <button type="button" className="btn-secondary" onClick={() => navigate('/dashboard')}>
            Cancel
          </button>
          <button type="submit" className="btn-primary" disabled={isSubmitting}>
            {isSubmitting ? 'Creating...' : 'Create Campaign'}
          </button>
        </div>
      </form>
    </div>
  );
}
