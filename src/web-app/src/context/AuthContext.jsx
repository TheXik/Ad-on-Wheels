import { createContext, useState } from 'react';

// eslint-disable-next-line react-refresh/only-export-components
export const AuthContext = createContext(null);

function decodeJwt(token) {
  try {
    const payload = token.split('.')[1];
    return JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')));
  } catch {
    return null;
  }
}

function readStoredUser() {
  const token = localStorage.getItem('token');
  if (!token) return null;
  const payload = decodeJwt(token);
  if (payload && payload.exp * 1000 > Date.now()) {
    return {
      token,
      role: payload.role,
      profileId: payload.profileID,
      email: payload.sub,
    };
  }
  localStorage.removeItem('token');
  return null;
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(readStoredUser);

  function login(token) {
    localStorage.setItem('token', token);
    const payload = decodeJwt(token);
    setUser({
      token,
      role: payload.role,
      profileId: payload.profileID,
      email: payload.sub,
    });
  }

  function logout() {
    localStorage.removeItem('token');
    setUser(null);
  }

  return (
    <AuthContext.Provider value={{ user, login, logout, loading: false }}>
      {children}
    </AuthContext.Provider>
  );
}
