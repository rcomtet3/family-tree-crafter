import Keycloak from 'keycloak-js';

export const keycloakConfig = {
  url: 'http://localhost:8180',
  realm: 'family-tree',
  clientId: 'family-tree-frontend',
};

export const keycloak = new Keycloak(keycloakConfig);

export const initKeycloak = () => {
  return keycloak.init({
    onLoad: 'login-required',
    redirectUri: window.location.origin,
  });
};
