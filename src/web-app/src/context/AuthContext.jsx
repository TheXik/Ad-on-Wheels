import { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext(null);

function decodeJwt(token) {
  try {
    const payload = token.split('.')[1];
    return JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')));
  } catch {
    return null;
  }
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      const payload = decodeJwt(token);
      if (payload && payload.exp * 1000 > Date.now()) {
        setUser({
          token,
          role: payload.role,
          profileId: payload.profileID,
          email: payload.sub,
        });
      } else {
        localStorage.removeItem('token');
      }
    }
    setLoading(false);
  }, []);

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
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
