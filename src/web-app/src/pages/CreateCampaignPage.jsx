import { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { campaigns } from '../services/api';

const MAX_IMAGES = 5;
const MAX_FILE_SIZE = 5 * 1024 * 1024;

export default function CreateCampaignPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const fileInputRef = useRef(null);
  const [form, setForm] = useState({
    name: '',
    description: '',
    startDate: '',
    endDate: '',
    budget: '',
    maxDrivers: '',
    ratePerKm: '0.10',
    estimatedReach: '',
  });
  const [images, setImages] = useState([]);
  const [dragOver, setDragOver] = useState(false);
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  function update(field, value) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  function addFiles(fileList) {
    const incoming = Array.from(fileList).filter((f) => f.type.startsWith('image/'));
    if (incoming.length === 0) return;

    const total = images.length + incoming.length;
    if (total > MAX_IMAGES) {
      setError(`Maximum ${MAX_IMAGES} images allowed. You already have ${images.length}.`);
      return;
    }

    const tooLarge = incoming.find((f) => f.size > MAX_FILE_SIZE);
    if (tooLarge) {
      setError(`"${tooLarge.name}" exceeds the 5 MB limit.`);
      return;
    }

    setError('');
    const newImages = incoming.map((file) => ({
      file,
      preview: URL.createObjectURL(file),
    }));
    setImages((prev) => [...prev, ...newImages]);
  }

  function removeImage(index) {
    setImages((prev) => {
      URL.revokeObjectURL(prev[index].preview);
      return prev.filter((_, i) => i !== index);
    });
  }

  useEffect(() => {
    return () => images.forEach((img) => URL.revokeObjectURL(img.preview));
  }, []);

  function handlePaste(e) {
    const files = e.clipboardData?.files;
    if (files?.length) {
      e.preventDefault();
      addFiles(files);
    }
  }

  function handleDrop(e) {
    e.preventDefault();
    setDragOver(false);
    addFiles(e.dataTransfer.files);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setIsSubmitting(true);
    try {
      const created = await campaigns.create({
        companyId: user.profileId,
        name: form.name,
        description: form.description,
        startDate: form.startDate,
        endDate: form.endDate,
        budget: parseFloat(form.budget),
        maxDrivers: parseInt(form.maxDrivers),
        ratePerKm: parseFloat(form.ratePerKm),
        estimatedReach: form.estimatedReach ? parseInt(form.estimatedReach) : null,
        status: 'RECRUITING',
      });

      if (images.length > 0) {
        const campaignId = created.id ?? created.data?.id;
        await campaigns.uploadImages(
          campaignId,
          images.map((img) => img.file)
        );
      }

      navigate('/dashboard');
    } catch (err) {
      setError(err.message);
    }
    setIsSubmitting(false);
  }

  return (
    <div className="page-container" onPaste={handlePaste}>
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

        <div className="form-group">
          <label>Campaign Images (max {MAX_IMAGES})</label>
          <div
            className={`image-dropzone${dragOver ? ' dragover' : ''}`}
            onClick={() => fileInputRef.current?.click()}
            onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
            onDragLeave={() => setDragOver(false)}
            onDrop={handleDrop}
          >
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              multiple
              hidden
              onChange={(e) => { addFiles(e.target.files); e.target.value = ''; }}
            />
            {images.length === 0 ? (
              <p className="dropzone-hint">
                Click, drag & drop, or paste images here
              </p>
            ) : (
              <div className="image-previews">
                {images.map((img, i) => (
                  <div key={i} className="image-thumb">
                    <img src={img.preview} alt="" />
                    <button
                      type="button"
                      className="thumb-remove"
                      onClick={(e) => { e.stopPropagation(); removeImage(i); }}
                    >
                      &times;
                    </button>
                  </div>
                ))}
                {images.length < MAX_IMAGES && (
                  <div className="image-thumb add-more">+</div>
                )}
              </div>
            )}
          </div>
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
            <label>Total Budget (EUR)</label>
            <input type="number" step="0.01" value={form.budget} onChange={(e) => update('budget', e.target.value)} required />
          </div>
          <div className="form-group">
            <label>Max Drivers</label>
            <input type="number" value={form.maxDrivers} onChange={(e) => update('maxDrivers', e.target.value)} required />
          </div>
          <div className="form-group">
            <label>Driver Pay per km (EUR)</label>
            <input type="number" step="0.01" min="0.01" value={form.ratePerKm} onChange={(e) => update('ratePerKm', e.target.value)} required />
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
