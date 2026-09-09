# Secrets Management

Secrets are managed by `sops-nix` and encrypted by `age` keys that can be stored in a yubikey/rs-key

## sops-nix

Basic set up for [sops-nix](https://github.com/Mic92/sops-nix/blob/master/README.md) as a secret manager.
This section assumes no yubikey/rs-key is used (see [default.nix](./default.nix) for more details).

### Generate Key

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

### Add Secrets

Declare secret entries in **`sops.secrets`**

```nix
sops.secrets = {
  "private_ssh_key" = {};
  "public_ssh_key" = {};
  "syncthing_password" = {};
};
```

Create and/or edit secret file

```sh
sops secrets.yaml
```

Update keys for a secret file (ensure at least one of the keys can still decrypt that file, if not, recreating `secrets.yaml` might be necessary)

```sh
sops updatekeys secrets.yaml

# use sudo if the keys are outside $HOME
sudo -E sops updatekeys secrets.yaml
```

## RS-Key

This section documents the procedure to setup an RP2350 USB as an encryption key for sops-nix (replacing `~/.config/sops/age/keys.txt` in the previous section)

### Enable CCID reader on NixOS

Follow the full [guide](https://themaxmur.github.io/RS-Key/linux.html#nixos-declarative) to add RS-Key identity to the CCID reader.
For all intents and purposes, just import `nixos.rs-key` into `nixosConfigurations` (see [rs-key.nix](../../nixos/rs-key.nix) for more details).

### Flash firmware

Clone the [RS-Key](https://github.com/TheMaxMur/RS-Key) repo to build the firmware with `VIDPID=Yubikey5`, which allows the RP2350 board
to act like a knockoff yubikey for `ykman` and `age-plugin-yubikey`

```sh
git clone https://github.com/TheMaxMur/RS-Key.git
cd RS-Key
nix develop

# 4MB board:
env VIDPID=Yubikey5 cargo build --release -p firmware
scripts/pt.sh target/thumbv8m.main-none-eabihf/release/firmware firmware-pt.elf

# 2MB board:
env VIDPID=Yubikey5 FLASH_SIZE=2M KVMAIN=896K cargo build --release -p firmware
scripts/pt.sh target/thumbv8m.main-none-eabihf/release/firmware firmware-pt.elf

# flash the firmware (hold BOOTSEL/BOOT button while plugging in, then run):
sudo picotool load firmware-pt.elf -t elf

# verify
lsusb | grep -i 1050        # Yubico VID (1209 for RS-Key)
pcsc_scan                   # should list a reader, not hang empty
```

### Set PIV management key

Change default management key to be compatible with `age-plugin-yubikey`

```sh
# current mgmt key (blank = default) and PIN (default 123456)
ykman piv access change-management-key -a TDES --protect
```

**(Optional)** Factory reset PIN/PUK if the default get scrambled mid-setup, then try the step above again

```sh
ykman piv reset   # PIN back to 123456, PUK 12345678
```

### Generate identity for RS-Key

It's game over if the hardware is breached anyway, so don't sweat the no-prompt policy 🙃.
Also possible to update its PIN/PUK in this step

```sh
age-plugin-yubikey --generate --slot 1 --pin-policy never --touch-policy never --name sops-nix --force
```

Then add its public key to `.sops.yaml` and run `sops updatekeys` for all the affected secret files

### Add RS-Key to `sops.age.keyFile`

Connect the keys to host that needs them and run

```sh
# delete previous keys.txt (run once)
shred -u ~/.config/sops/age/keys.txt

# rerun this for each rs-key (connect them one at a time)
age-plugin-yubikey --identity --slot 1 >> ~/.config/sops/age/keys.txt
```
