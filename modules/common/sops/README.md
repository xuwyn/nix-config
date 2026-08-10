# Secrets Management

Secrets are managed by `sops-nix` and encrypted by `age`

## Generate Key

Create key directory

```sh
mkdir -p ~/.config/sops/age
```

Generate `age` private and public keys

```sh
age-keygen -o ~/.config/sops/age/keys.txt
```

Extract `age` public key and copy it to `.sops.yaml`

```sh
age-keygen -y ~/.config/sops/age/keys.txt
```

Or generate `age` public key from ssh key and copy it to `.sops.yaml`

```sh
cat ~/.ssh/id_ed25519.pub | ssh-to-age
```

## Add Secrets

Add new entry to **`sops.secrets`**

```nix
sops = {
  secrets = {
    "private_ssh_key" = {};
    "public_ssh_key" = {};
    "syncthing_password" = {};
  };
};
```

Create and/or edit secret file

```sh
sops secrets.yaml
```
