export default function RoleMismatchModal({ open, onClose }) {
  if (!open) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-card" onClick={(e) => e.stopPropagation()}>
        <div className="modal-icon">!</div>
        <h2>Account already in use</h2>
        <p>
          This account is registered as a driver. You can log in as a driver
          in the Ad on Wheels iOS application.
        </p>
        <button type="button" className="btn-primary" onClick={onClose}>
          Close
        </button>
      </div>
    </div>
  );
}
