# Tinyauth

More info here: https://tinyauth.app/docs/guides/nginx-proxy-manager

## Deploy

Use the dedicated playbook (or `make setup-tinyauth` from the repo root):

```bash
ansible-playbook playbooks/setup_tinyauth.yml --vault-password-file .ansible-vault-password
```

## Required `vars/host_secrets.yml` structure

Define a top-level `tinyauth` mapping (names must match what `playbooks/setup_tinyauth.yml` passes into the role):

```yaml
tinyauth:
  app_url: "https://auth.example.com"
  users:
    - username: "admin"
      password_hash: "$apr1$..." # htpasswd-style hash
  github_oauth_client_id: "your-github-oauth-app-client-id"
  github_oauth_client_secret: "your-github-oauth-app-secret"
  oauth_whitelist:
    - "github-username-or-email"
```

Optional role defaults (override in the playbook or inventory if needed):

- `tinyauth_image_tag` (default in role: `v5`; playbook sets `v5` explicitly)
- `tinyauth_port` (default `3399`; reserved for future use — compose currently relies on the default app port inside the image)

## Protecting a service

E.g., for NGINX:

```
auth_request /tinyauth; # Can be anyhting
error_page 401 = @tinyauth_login;

location /tinyauth {
  proxy_pass http://tinyauth:3000/api/auth/nginx;
  proxy_set_header x-forwarded-proto $scheme;
  proxy_set_header x-forwarded-host $http_host;
  proxy_set_header x-forwarded-uri $request_uri;
}

location @tinyauth_login {
  return 302 http://tinyauth.example.com/login?redirect_uri=$scheme://$http_host$request_uri; # make sure to replace the http://tinyauth.example.com with your own app URL
}
```
