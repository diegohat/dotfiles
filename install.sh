#!/bin/bash

# Salvar chave pública do agent
mkdir -p ~/.ssh
ssh-add -L > ~/.ssh/id_ed25519.pub

# Configurar git - usuário
git config --global user.name "diegohat"
git config --global user.email "diego.hat7@gmail.com"

# Configurar git - assinatura SSH
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true

# Signatários permitidos
mkdir -p ~/.config/git
echo "diego.hat7@gmail.com namespaces=\"git\" $(cat ~/.ssh/id_ed25519.pub)" > ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
