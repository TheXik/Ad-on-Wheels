import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { GoogleLogin } from '@react-oauth/google';
import { useAuth } from '../context/useAuth';
import { auth } from '../services/api';

export default function GoogleLoginButton({ onRoleMismatch }) {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [error, setError] = useState('');

  async function handleSuccess(credentialResponse) {
    setError('');
    try {
      const data = await auth.googleLogin(credentialResponse.credential, 'COMPANY');
      login(data.token);
      navigate('/dashboard');
    } catch (err) {
      if (err.code === 2007 && onRoleMismatch) {
        onRoleMismatch();
      } else {
        setError(err.message);
      }
    }
  }

  function handleError() {
    setError('Google Sign-In failed. Please try again.');
  }

  return (
    <div className="google-signin">
      <div className="or-divider">
        <span>or</span>
      </div>
      <div className="google-button-wrapper">
        <GoogleLogin
          onSuccess={handleSuccess}
          onError={handleError}
          theme="outline"
          size="large"
          width="100%"
          text="signin_with"
          shape="rectangular"
        />
      </div>
      {error && <div className="error-message">{error}</div>}
    </div>
  );
}
