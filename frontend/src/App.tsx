import { useAuth } from './auth/AuthContext';
import { useState, useEffect, useRef } from 'react';

function App() {
  const { isAuthenticated, user, login, logout, isLoading } = useAuth();
  const [showLoginForm, setShowLoginForm] = useState(false);
  const isLoggingIn = useRef(false);

  useEffect(() => {
    if (isAuthenticated) {
      setShowLoginForm(false);
    }
  }, [isAuthenticated]);

  const handleLogin = () => {
    isLoggingIn.current = true;
    login();
  };

  if (isLoading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        color: 'white',
        fontFamily: 'Arial, sans-serif'
      }}>
        <div style={{ textAlign: 'center' }}>
          <h1>Family Tree Crafter</h1>
          <p>Connecting to Keycloak...</p>
          <div style={{ 
            width: '40px', 
            height: '40px', 
            border: '4px solid rgba(255,255,255,0.3)',
            borderTopColor: 'white',
            borderRadius: '50%',
            animation: 'spin 1s linear infinite',
            margin: '20px auto'
          }} />
        </div>
        <style>{`
          @keyframes spin {
            to { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    );
  }

  if (!isAuthenticated && !showLoginForm) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        color: 'white',
        fontFamily: 'Arial, sans-serif'
      }}>
        <div style={{ textAlign: 'center', background: 'rgba(255,255,255,0.1)', padding: '40px', borderRadius: '16px' }}>
          <h1>Family Tree Crafter</h1>
          <p style={{ marginBottom: '20px' }}>Please log in to continue</p>
          <button 
            onClick={handleLogin} 
            style={{ 
              padding: '12px 24px', 
              fontSize: '16px',
              background: 'white',
              color: '#667eea',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontWeight: 'bold'
            }}
          >
            Login with Keycloak
          </button>
        </div>
      </div>
    );
  }

  if (!isAuthenticated && showLoginForm) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        color: 'white',
        fontFamily: 'Arial, sans-serif'
      }}>
        <div style={{ textAlign: 'center', background: 'rgba(255,255,255,0.1)', padding: '40px', borderRadius: '16px' }}>
          <h1>Family Tree Crafter</h1>
          <p>Redirecting to login...</p>
        </div>
      </div>
    );
  }

  return (
    <div style={{ 
      display: 'flex', 
      flexDirection: 'column',
      justifyContent: 'center', 
      alignItems: 'center', 
      height: '100vh',
      fontFamily: 'Arial, sans-serif'
    }}>
      <h1>Bonjour {user?.username || 'User'}</h1>
      <button 
        onClick={logout} 
        style={{ 
          padding: '10px 20px', 
          fontSize: '14px',
          cursor: 'pointer'
        }}
      >
        Déconnexion
      </button>
    </div>
  );
}

export default App;
