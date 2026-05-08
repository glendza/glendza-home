Create a new Ansible service scaffold in this repository.

Arguments:
- description: short free-text description of the service to scaffold

Parameter handling:
- Do not ask for slug/title/secrets key separately.
- Derive everything from `description`.
- Infer:
  - `service_slug` as kebab-case identifier (used in paths and Makefile target)
  - `service_title` as human-readable title (used in README/playbook name)
  - `secrets_key` as snake_case top-level key for `vars/host_secrets.yml`
  - whether to create `templates/env.j2` based on service needs mentioned in description
- If derivation is ambiguous, pick the most conventional naming and proceed.

Follow these rules exactly:
1. Generate all of the following:
   - `playbooks/setup_<service_slug>.yml`
   - `roles/<service_slug>/README.md`
   - `roles/<service_slug>/defaults/main.yml`
   - `roles/<service_slug>/tasks/main.yml`
   - `roles/<service_slug>/templates/compose.yml.j2`
   - `roles/<service_slug>/templates/env.j2` only when service requires env-file rendering
2. Update:
   - `Makefile`:
     - add `setup-<service_slug>` to `.PHONY`
     - add a `setup-<service_slug>` target that runs `ansible-playbook playbooks/setup_<service_slug>.yml --vault-password-file $(ANSIBLE_PASSWORD_FILE)`
   - root `README.md`:
     - add the new role under the Roles section
     - add `make setup-<service_slug>` under Playbook Targets
   - `vars/host_secrets.example.yml` with a complete example structure under `<secrets_key>:`
3. Keep naming consistent with existing roles:
   - role vars prefixed with `<service_slug>_`
   - playbook reads `vars/host_secrets.yml`
   - use `docker_user: "{{ username }}"` and `docker_group: "{{ username }}"`
   - if networks are needed, define `<service_slug>_docker_networks` in playbook role vars (or use role default `[]`) and create Docker networks via `docker_network` role from that playbook-level list
   - role defaults for Docker networks must be empty lists (`<service_slug>_docker_networks: []`), never environment-specific network names
   - **in `playbooks/setup_<service_slug>.yml`, hardcode** `<service_slug>_service_directory`, volume paths (config/data), **`image_tag`**, and **`container_name`** as literals under `include_role` / role `vars` (see `setup_actual.yml`, `setup_paperless.yml`, `setup_garage.yml`); **do not** put those fields only under the vault secrets dict—secrets should be tokens, URLs, networks, and other per-deployment values, not repo-standard paths
   - never put `*_service_directory`, volume path vars (`*_config_directory`, `*_data_directory`, etc.), `*_image_tag`, or `*_container_name` in `defaults/main.yml`; these must be set in the playbook role vars
   - do not put non-secret runtime wiring in `vars/host_secrets.yml` examples (docker networks, port mappings, expose lists, host paths, container identity); keep those in playbook vars or role defaults
4. CRITICAL style and safety rules:
   - never use `| default(...)` in templates
   - never use `| default(...)` in playbooks
   - in `compose.yml.j2`, wrap optional blocks (`ports`, `expose`, `networks`, `volumes`, `environment`) in `{% if ... %}` so empty values do not render invalid/unused sections
   - do not hardcode defaults in templates
   - only put sensible defaults in `defaults/main.yml`
   - required secrets/required endpoints must have no defaults (comment them as required)
   - do not add empty string placeholders as defaults for required values
   - in `roles/<service_slug>/tasks/main.yml`, add explicit fail-fast validation for required inputs using `ansible.builtin.assert`
   - place all validation tasks first (top of file), before any state-changing tasks such as file creation, templating, package install, or container/service actions
   - keep network configuration as arrays
   - default timezone should be `Etc/UTC` when timezone is applicable
5. README requirements:
   - make `roles/<service_slug>/README.md` role-centric (what the role does and which role variables it accepts), not playbook orchestration-centric
   - start the README with a short, abstract role description (capability-focused), not an implementation step breakdown
   - include a role variables table with: variable name, required/optional, secret/non-secret, default, and short description
   - include a minimal role input example (only required inputs)
   - clearly separate required and optional fields
   - include a short notes section about defaults and required values
   - include a Caddy integration example when service exposes HTTP(S) UI/endpoints:
     - show `caddy.public_sites` example
     - show optional `caddy.protected_sites` example
     - explain which ports stay direct host ports vs what Caddy fronts

Implementation checklist:
- mirror structure/pattern from existing roles like `garage`, `paperless`, `filebrowser`, `actual_budget`
- use ASCII only
- after edits, run lint/diagnostics for changed files if available and fix any introduced issues
- do not modify unrelated files

When done:
- print a concise summary of created/updated files
- print exactly which required values the user still must set in `vars/host_secrets.yml`
