import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { keycloak, initKeycloak } from './keycloak';

interface AuthContextType {
  isAuthenticated: boolean;
  token: string | null;
  user: any;
  login: () => void;
  logout: () => void;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [token, setToken] = useState<string | null>(null);
  const [user, setUser] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const init = async () => {
      try {
        await initKeycloak();
        
        if (keycloak.authenticated) {
          setIsAuthenticated(true);
          setToken(keycloak.token || null);
          
          try {
            const userInfo = await keycloak.loadUserProfile();
            setUser(userInfo);
          } catch (e) {
            console.log('Could not load user profile');
          }
        }
      } catch (error) {
        console.error('Keycloak initialization failed:', error);
      } finally {
        setIsLoading(false);
      }
    };

    init();
  }, []);

  const login = () => {
    keycloak.login();
  };

  const logout = () => {
    keycloak.logout({ redirectUri: window.location.origin });
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, token, user, login, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
