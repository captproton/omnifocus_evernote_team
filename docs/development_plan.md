# Obsidian Migration Development Plan

## Objective
Migrate the current project orchestration workflow from Evernote to Obsidian. This will simplify the architecture by removing reliance on a cloud API and replacing the manual note-creation process with automated local Markdown file generation.

## Phase 1: Setup and Configuration (Completed: 2026-03-05)
- [x] Establish a configuration mechanism (e.g., `dotenv` gem or `config/application.yml`) to store environment variables.
- [x] Move hardcoded paths (like `~/Documents/projects/`) into the new configuration file.
- [x] Define the `OBSIDIAN_VAULT_PATH` and the `OBSIDIAN_VAULT_NAME` in the configuration.

## Phase 2: Create Obsidian Integration
- [ ] Create a new service or add logic to the `Project` model to handle Obsidian note generation.
- [ ] Automate note generation: Use `File.write` to create a new Markdown (`.md`) file directly in the user's `OBSIDIAN_VAULT_PATH` when a project is initialized.
- [ ] Implement an Obsidian URI generator (e.g., `obsidian://open?vault=VaultName&file=project_name`) to link back to the newly created note.

## Phase 3: Remove Evernote Technical Debt
- [ ] Delete `lib/evernote-utils.rb` entirely.
- [ ] Remove the `evernote_oauth` and `oauth` gems from the `Gemfile` and run `bundle lock`.
- [ ] Remove the manual user prompts asking for the Evernote App Link in `project_action`.

## Phase 4: Refactor and Clean Up
- [ ] Remove duplicate `.inetloc` file generation logic from `project_action` and rely solely on `LinkFile`.
- [ ] Update OmniFocus integration to accept the new Obsidian URI instead of the Evernote link.
- [ ] Fix URL encoding: Replace manual `.gsub(/\s/, '%20')` with Ruby's built-in `URI.encode_www_form_component` across the app (`project.rb` and `project_action`).
- [ ] Test the full `generate` workflow to ensure directories, notes, and OmniFocus projects are created correctly (keeping the manual link copying step for OmniFocus since AppleScript is Pro-only). 
