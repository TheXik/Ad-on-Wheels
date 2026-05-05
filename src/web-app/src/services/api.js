const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080';

export function resolveImageUrl(path) {
  if (!path) return null;
  if (path.startsWith('http')) return path;
  let normalized = path;
  if (normalized.startsWith('/drivers/images/') || normalized.startsWith('/campaigns/images/')) {
    normalized = '/api' + normalized;
  }
  return `${API_BASE}${normalized.startsWith('/') ? '' : '/'}${normalized}`;
}

async function request(path, options = {}) {
  const token = localStorage.getItem('token');
  const headers = { 'Content-Type': 'application/json', ...options.headers };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${API_BASE}${path}`, { ...options, headers });
  if (!res.ok) {
    const body = await res.json().catch(() => null);
    const err = new Error(body?.error?.message || `Request failed: ${res.status}`);
    err.code = body?.error?.internalCode;
    err.status = res.status;
    throw err;
  }

  const contentType = res.headers.get('content-type');
  if (contentType?.includes('text/csv')) return res.blob();
  if (res.status === 204) return null;

  const json = await res.json();
  return json.data !== undefined ? json.data : json;
}

export const auth = {
  login: (email, password) =>
    request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password, expectedRole: 'COMPANY' }),
    }),
  register: (email, password, name, role) =>
    request('/auth/register', {
      method: 'POST',
      body: JSON.stringify({ email, password, name, role }),
    }),
  googleLogin: (idToken, role) =>
    request('/auth/google', {
      method: 'POST',
      body: JSON.stringify({ idToken, role }),
    }),
};

export const campaigns = {
  getByCompany: (companyId, status) => {
    const params = status ? `?status=${status}` : '';
    return request(`/api/campaigns/company/${companyId}${params}`);
  },
  getById: (id) => request(`/api/campaigns/${id}`),
  create: (data) =>
    request('/api/campaigns', { method: 'POST', body: JSON.stringify(data) }),
  uploadImages: (campaignId, files) => {
    const form = new FormData();
    files.forEach((f) => form.append('files', f));
    const token = localStorage.getItem('token');
    const headers = {};
    if (token) headers['Authorization'] = `Bearer ${token}`;
    return fetch(`${API_BASE}/api/campaigns/${campaignId}/images`, {
      method: 'POST',
      headers,
      body: form,
    }).then((res) => {
      if (!res.ok) throw new Error(`Image upload failed: ${res.status}`);
      return res.json();
    });
  },
  getApplications: (companyId) =>
    request(`/api/campaigns/${companyId}/applications`),
  acceptApplication: (applicationId) =>
    request(`/api/campaigns/applications/${applicationId}`, {
      method: 'PATCH',
      body: JSON.stringify({ status: 'ACCEPTED' }),
    }),
  declineApplication: (applicationId) =>
    request(`/api/campaigns/applications/${applicationId}`, {
      method: 'PATCH',
      body: JSON.stringify({ status: 'DECLINED' }),
    }),
  exportCampaignCsv: (campaignId) => request(`/api/campaigns/${campaignId}/export`),
  getCoverage: (campaignId) => request(`/api/campaigns/${campaignId}/coverage`),
};

export const companies = {
  getById: (id) => request(`/api/companies/${id}`),
};

export const messages = {
  getInbox: (userId) => request(`/api/messages/inbox/${userId}`),
  getConversation: (campaignId, userId1, userId2) =>
    request(`/api/messages/conversation?campaignId=${campaignId}&userId1=${userId1}&userId2=${userId2}`),
  send: (data) =>
    request('/api/messages', { method: 'POST', body: JSON.stringify(data) }),
  markRead: (messageId) =>
    request(`/api/messages/${messageId}/read`, { method: 'PATCH' }),
};

export const drivers = {
  getById: (id) => request(`/api/drivers/${id}`),
};

export const applicationsWithDrivers = {
  get: (companyId) => request(`/api/companies/${companyId}/applications-with-drivers`),
};

export const campaignStats = {
  getByCompany: (companyId) => request(`/api/companies/${companyId}/campaign-stats`),
  exportCsv: (companyId) => request(`/api/companies/${companyId}/export-csv`),
};
