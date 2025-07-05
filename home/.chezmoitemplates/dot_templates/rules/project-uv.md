# Python Project Rules – Leverage `uv` for All Python Commands

1. Use `uv` for all Python package installation, dependency management, and environment setup.
2. Initialize new projects with `uv init`.
3. Add/remove dependencies with `uv add`/`uv remove`.
4. Lock and install dependencies using `uv lock` and `uv install`.
5. Always run Python scripts and tools via `uv run`, `uv tool run`, or `uvx`.
6. Manage Python versions using `uv python install` and `uv python pin`.
7. Maintain configuration in `pyproject.toml` and `.python-version`.
8. Document all `uv` usage in project README files.
9. Do not use `pip`, `pip-tools`, or system Python directly.
10. Regularly update and clean environments using `uv update` and `uv clean`.

