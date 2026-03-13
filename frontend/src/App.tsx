import { useAuth } from './auth/AuthContext';
import { useEffect } from 'react';

function App() {
  const { isAuthenticated, user, login, logout, isLoading } = useAuth();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      login();
    }
  }, [isLoading, isAuthenticated, login]);

  if (isLoading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh',
        background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
        color: 'white',
        fontFamily: 'system-ui, -apple-system, sans-serif'
      }}>
        <div style={{ textAlign: 'center' }}>
          <h1 style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>Family Tree Crafter</h1>
          <p style={{ opacity: 0.8 }}>Connecting to Keycloak...</p>
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

  if (!isAuthenticated) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh',
        background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
        color: 'white',
        fontFamily: 'system-ui, -apple-system, sans-serif'
      }}>
        <div style={{ textAlign: 'center', background: 'rgba(255,255,255,0.08)', padding: '50px 60px', borderRadius: '24px', backdropFilter: 'blur(10px)', border: '1px solid rgba(255,255,255,0.1)' }}>
          <h1 style={{ fontSize: '2.5rem', marginBottom: '0.5rem' }}>Family Tree Crafter</h1>
          <p style={{ marginBottom: '30px', opacity: 0.8 }}>Redirecting to login...</p>
        </div>
      </div>
    );
  }

  return (
    <div style={{ 
      minHeight: '100vh',
      background: 'linear-gradient(180deg, #f0f4f8 0%, #d9e2ec 100%)',
      fontFamily: 'system-ui, -apple-system, sans-serif'
    }}>
      {/* Header */}
      <header style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center', 
        padding: '20px 40px',
        background: 'white',
        boxShadow: '0 2px 10px rgba(0,0,0,0.08)'
      }}>
        <h1 style={{ margin: 0, color: '#1a1a2e', fontSize: '1.5rem' }}>Family Tree Crafter</h1>
        <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
          <span style={{ color: '#486581', fontWeight: '500' }}>
            Bonjour <strong>{user?.username || 'User'}</strong>
          </span>
          <button 
            onClick={logout} 
            style={{ 
              padding: '8px 16px', 
              fontSize: '14px',
              background: '#e94560',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontWeight: '500',
              transition: 'background 0.2s'
            }}
          >
            Déconnexion
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main style={{ 
        padding: '40px', 
        maxWidth: '1200px', 
        margin: '0 auto' 
      }}>
        {/* Add Person Card */}
        <div 
          style={{ 
            background: 'white',
            borderRadius: '16px',
            padding: '40px',
            textAlign: 'center',
            cursor: 'pointer',
            border: '3px dashed #c9d6e3',
            transition: 'border-color 0.2s, transform 0.2s',
            boxShadow: '0 4px 6px rgba(0,0,0,0.05)'
          }}
        >
          <div style={{ 
            width: '80px', 
            height: '80px', 
            borderRadius: '50%', 
            background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 20px',
            boxShadow: '0 4px 15px rgba(102, 126, 234, 0.4)'
          }}>
            <span style={{ color: 'white', fontSize: '48px', fontWeight: '300', lineHeight: '80px' }}>+</span>
          </div>
          <p style={{ 
            color: '#486581', 
            fontSize: '18px', 
            fontWeight: '500',
            margin: 0
          }}>
            Ajouter la première personne
          </p>
          <p style={{ 
            color: '#829ab1', 
            fontSize: '14px', 
            marginTop: '8px'
          }}>
            Commencez votre arbre généalogique
          </p>
        </div>
      </main>
    </div>
  );
}

export default App;
