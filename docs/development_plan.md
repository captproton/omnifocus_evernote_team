# Obsidian Migration Development Plan

## Objective
Migrate the current project orchestration workflow from Evernote to Obsidian. This will simplify the architecture by removing reliance on a cloud API and replacing the manual note-creation process with automated local Markdown file generation.

## Phase 1: Setup and Configuration (Completed: 2026-03-05)
- [x] Establish a configuration mechanism (e.g., `dotenv` gem or `config/application.yml`) to store environment variables.
- [x] Move hardcoded paths (like `~/Documents/projects/`) into the new configuration file.
- [x] Define the `OBSIDIAN_VAULT_PATH` and the `OBSIDIAN_VAULT_NAME` in the configuration.

## Phase 2: Create Obsidian Integration (Completed: 2026-03-05)
- [x] Create a new service or add logic to the `Project` model to handle Obsidian note generation.
- [x] Automate note generation: Use `File.write` to create a new Markdown (`.md`) file directly in the user's `OBSIDIAN_VAULT_PATH` when a project is initialized.
- [x] Implement an Obsidian URI generator (e.g., `obsidian://open?vault=VaultName&file=project_name`) to link back to the newly created note.

## Phase 3: Remove Evernote Technical Debt (Completed: 2026-03-05)
- [x] Delete `lib/evernote-utils.rb` entirely.
- [x] Remove the `evernote_oauth` and `oauth` gems from the `Gemfile` and run `bundle lock`.
- [x] Remove the manual user prompts asking for the Evernote App Link in `project_action`.

## Phase 4: Refactor and Clean Up (Completed: 2026-03-05)

This phase focuses on consolidating logic, standardizing URL encoding, and performing a final end-to-end audit of the Obsidian-centric workflow.

### Architectural Consolidations
- **[MODIFY] [project_action.rb](file:///Users/carltanner/ruby_apps/omnifocus_evernote_team/bin/project_action.rb)**: Remove any remaining duplicate `.inetloc` file generation logic and ensure it uses the `LinkFile` model exclusively.
- **[MODIFY] [project.rb](file:///Users/carltanner/ruby_apps/omnifocus_evernote_team/models/project.rb)**: Standardize URL encoding using `URI.encode_www_form_component` instead of manual `gsub`.

### Final Workflow Audit
- **End-to-End Verification**: Manually verify the `project_action generate` command:
    1. Folder creation.
    2. Obsidian note creation (with proper metadata).
    3. README creation.
    4. OmniFocus link generation (including Obsidian URI).

## Verification Plan

### Automated Tests
- Run `bundle exec rspec` to ensure 100% pass rate.
- Add specific test cases for `URI.encode_www_form_component` edge cases (e.g., symbols in project titles).

### Manual Verification
- Execute `bin/project_action generate "End-to-End Test"` and verify all artifacts and links.
