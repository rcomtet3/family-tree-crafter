import Keycloak from 'keycloak-js';

export const keycloakConfig = {
  url: 'http://localhost:8180',
  realm: 'family-tree',
  clientId: 'family-tree-frontend',
};

export const keycloak = new Keycloak(keycloakConfig);

let initialized = false;

export const initKeycloak = () => {
  if (!initialized) {
    initialized = true;
    return keycloak.init({
      onLoad: 'check-sso',
      silentCheckSsoRedirectUri: window.location.origin + '/silent-check-sso.html',
      pkceMethod: 'S256',
      redirectUri: window.location.origin,
    });
  }
  return Promise.resolve(keycloak.authenticated);
};
