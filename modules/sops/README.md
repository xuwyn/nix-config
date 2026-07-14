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

Extract public key and copy it to `.sops.yaml`

```sh
age-keygen -y ~/.config/sops/age/keys.txt
```

## Add Secrets

Add new entry to **`sops.secrets`** in [default.nix](./default.nix)

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
