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
   ./bin/project_action.rb generate "My Awesome Project"
   ```

## Alfred Integration

You can trigger this workflow directly from Alfred for a seamless experience:

1. **Create a New Workflow** in Alfred.
2. **Add a Keyword Input**:
   - Keyword: `proj` (or your preference)
   - Argument: `Required`
   - Title: `Create New Project: {query}`
3. **Add a "Terminal Command" Action**:
   - Command:
     ```bash
     /Users/carltanner/ruby_apps/omnifocus_obsidian_team/bin/project_action.sh "{query}"
     ```
4. **Connect them**: Link the Keyword to the Terminal Command.

> [!TIP]
> Using the `.sh` script is recommended as it automatically loads the correct Ruby environment (via asdf) and project context.

Now, typing `proj My New Project` in Alfred will launch the terminal and start the orchestration wizard automatically!

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
