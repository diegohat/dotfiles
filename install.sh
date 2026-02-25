#!/bin/bash
set -e

echo "🔧 Configurando dotfiles..."

# ─── Identidade Git ───────────────────────────────────────────
git config --global user.email "diego.hat7@gmail.com"
git config --global user.name "diegohat"

# ─── SSH_AUTH_SOCK dinâmico (VS Code dev containers no macOS) ─
BASHRC="$HOME/.bashrc"
SOCK_LINE='export SSH_AUTH_SOCK=$(ls /tmp/vscode-ssh-auth-*.sock 2>/dev/null | head -1)'

if ! grep -qF "vscode-ssh-auth" "$BASHRC" 2>/dev/null; then
    echo "" >> "$BASHRC"
    echo "# VS Code SSH agent forwarding (dev container)" >> "$BASHRC"
    echo "$SOCK_LINE" >> "$BASHRC"
fi

# Aplica na sessão atual
export SSH_AUTH_SOCK=$(ls /tmp/vscode-ssh-auth-*.sock 2>/dev/null | head -1)

# ─── Assinatura SSH ───────────────────────────────────────────
mkdir -p ~/.ssh ~/.config/git

if ssh-add -L &>/dev/null; then
    ssh-add -L > ~/.ssh/id_ed25519.pub
    echo "✅ Chave pública exportada do agent"
else
    echo "⚠️  Agent SSH não disponível. Assinatura não configurada."
    exit 0
fi

git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true

echo "diego.hat7@gmail.com namespaces=\"git\" $(cat ~/.ssh/id_ed25519.pub)" \
    > ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers

echo "✅ Dotfiles configurados com sucesso!"
