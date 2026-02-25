#!/bin/bash
set -e

echo "🔧 Configurando dotfiles..."

# ─── Identidade Git ───────────────────────────────────────────
git config --global user.email "diego.hat7@gmail.com"
git config --global user.name "diegohat"

# ─── Helper de assinatura SSH ─────────────────────────────────
mkdir -p ~/.local/bin

cat > ~/.local/bin/setup-git-signing.sh << 'EOF'
#!/bin/bash
FLAG="$HOME/.config/git/.signing-configured"

if [ -f "$FLAG" ]; then
    exit 0
fi

# Aguarda o agente SSH do VS Code ficar disponível (até 30s)
for i in $(seq 1 15); do
    export SSH_AUTH_SOCK=$(ls /tmp/vscode-ssh-auth-*.sock 2>/dev/null | head -1)
    if ssh-add -L &>/dev/null; then
        break
    fi
    sleep 2
done

if ! ssh-add -L &>/dev/null; then
    echo "⚠️  Agent SSH não disponível. Assinatura não configurada."
    exit 0
fi

mkdir -p ~/.ssh ~/.config/git
ssh-add -L > ~/.ssh/id_ed25519.pub

git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true

echo "diego.hat7@gmail.com namespaces=\"git\" $(cat ~/.ssh/id_ed25519.pub)" \
    > ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers

touch "$FLAG"
echo "✅ Assinatura SSH configurada"
EOF

chmod +x ~/.local/bin/setup-git-signing.sh

# Roda em background — não bloqueia o dotfiles e espera o agente SSH
~/.local/bin/setup-git-signing.sh &

# ─── .bashrc: só exporta o SSH_AUTH_SOCK ──────────────────────
BASHRC="$HOME/.bashrc"

if ! grep -qF "vscode-ssh-auth" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" << 'EOF'

# VS Code SSH agent forwarding (dev container)
export SSH_AUTH_SOCK=$(ls /tmp/vscode-ssh-auth-*.sock 2>/dev/null | head -1)
EOF
fi

echo "✅ Dotfiles configurados com sucesso!"
