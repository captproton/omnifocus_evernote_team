# OmniFocus Obsidian Team

A Ruby-based CLI to orchestrate project creation across OmniFocus and Obsidian.

## Features
- **Automated Directory Creation**: Generates a standard project folder structure.
- **Obsidian Integration**: Automatically creates a project note in your Obsidian vault with standard metadata.
- **OmniFocus Integration**: Generates an OmniFocus project/task with deep links back to the project folder and Obsidian note.
- **Path Normalization**: Handles custom base paths and Obsidian vault locations via environment variables.

## Getting Started

1. **Configure Environment**:
   Create a `.env` file in the root directory:
   ```bash
   PROJECTS_BASE_PATH="~/Documents/projects/"
   OBSIDIAN_VAULT_PATH="~/Documents/MyVault/"
   OBSIDIAN_VAULT_NAME="MyVault"
   ```

2. **Generate a Project**:
   Run the wizard to set up everything:
   ```bash
   ./project_action generate "My Awesome Project"
   ```

## Development

### Running Tests
```bash
bundle exec rspec
```

### Key Components
- `Project`: Core model managing project metadata and Obsidian generation.
- `ProjectAction`: CLI interface (built with Thor).
- `LinkFile`: Handles creation of `.inetloc` files for macOS deep linking.

---
*Migrated from Evernote to Obsidian in March 2026.*
