#!/usr/bin/env bash
set -u
vsix="$(cd "$(dirname "$0")/.." && pwd)/pyret-parley-http.vsix"
if command -v code >/dev/null 2>&1 && code --install-extension "$vsix" --force; then
  exit 0
fi
for server in "$HOME"/.vscode-remote/bin/*/bin/code-server "$HOME"/.vscode-server/bin/*/bin/code-server; do
  if [ -x "$server" ] && "$server" --install-extension "$vsix" --force; then
    exit 0
  fi
done
echo "install-pyret-vsix: no VS Code server found; install $vsix by hand (right-click > Install Extension VSIX)" >&2
exit 1
