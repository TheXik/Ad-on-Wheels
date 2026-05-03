import { useEffect, useState } from 'react';
import { MapContainer, TileLayer, Polyline, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { campaigns as campaignsApi } from '../services/api';

// Prague city centre is the safe default if no rides are recorded yet.
const DEFAULT_CENTER = [50.0755, 14.4378];
const DEFAULT_ZOOM = 12;

// UC014 — Coverage / heat-map.
// Multi-route map for a single campaign. Verified rides render solid blue;
// unverified rides render dashed in a lighter tone. The viewport auto-fits
// the bounding box of every coordinate across all routes when the data
// arrives.
export default function CampaignCoverageMap({ campaignId }) {
  const [routes, setRoutes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    async function load() {
      try {
        const data = await campaignsApi.getCoverage(campaignId);
        if (!cancelled) {
          setRoutes(Array.isArray(data?.routes) ? data.routes : []);
        }
      } catch (err) {
        if (!cancelled) setError(err.message || 'Failed to load coverage map');
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    load();
    return () => {
      cancelled = true;
    };
  }, [campaignId]);

  const verifiedCount = routes.filter((r) => r.verified).length;
  const allPoints = routes.flatMap((r) =>
    (r.route || []).map((p) => [p.lat, p.lon])
  );

  return (
    <div className="coverage-map">
      <div className="coverage-map-header">
        <h3>Coverage Map</h3>
        <div className="coverage-map-meta">
          <span>{routes.length} {routes.length === 1 ? 'ride' : 'rides'}</span>
          <span aria-hidden="true">·</span>
          <span>{verifiedCount} verified</span>
        </div>
      </div>

      {loading && <p className="coverage-map-status">Loading coverage…</p>}
      {error && <p className="coverage-map-status error">{error}</p>}
      {!loading && !error && routes.length === 0 && (
        <p className="coverage-map-status">
          No rides recorded yet for this campaign.
        </p>
      )}

      <div className="coverage-map-container">
        <MapContainer
          center={DEFAULT_CENTER}
          zoom={DEFAULT_ZOOM}
          scrollWheelZoom={false}
          style={{ height: '420px', width: '100%' }}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          {routes.map((r) => {
            const coords = (r.route || []).map((p) => [p.lat, p.lon]);
            if (coords.length < 2) return null;
            return (
              <Polyline
                key={r.rideId}
                positions={coords}
                pathOptions={
                  r.verified
                    ? { color: '#2563eb', weight: 4, opacity: 0.9 }
                    : { color: '#94a3b8', weight: 3, opacity: 0.75, dashArray: '6 6' }
                }
              />
            );
          })}
          <FitBounds points={allPoints} />
        </MapContainer>
      </div>

      <div className="coverage-map-legend">
        <span className="coverage-legend-item">
          <span className="coverage-legend-swatch verified" /> Verified
        </span>
        <span className="coverage-legend-item">
          <span className="coverage-legend-swatch unverified" /> Unverified
        </span>
      </div>
    </div>
  );
}

// Auto-fit the map to the union of every recorded coordinate. Runs whenever
// the points list changes (e.g. after the fetch completes). A small padding
// is requested so the polylines aren't clipped by the viewport edges.
function FitBounds({ points }) {
  const map = useMap();
  useEffect(() => {
    if (!points || points.length === 0) return;
    const bounds = L.latLngBounds(points);
    if (bounds.isValid()) {
      map.fitBounds(bounds, { padding: [24, 24] });
    }
  }, [points, map]);
  return null;
}
