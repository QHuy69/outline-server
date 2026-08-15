# QHuy69 multi-architecture image

This fork publishes `ghcr.io/qhuy69/outline-server:latest` as one Docker
manifest containing both `linux/amd64` (x86_64) and `linux/arm64`
(aarch64/arm64). Docker chooses the correct image for each VPS automatically.

The installer does not build on the local computer or on the VPS. GitHub
Actions builds both images, and the VPS only downloads the installer and pulls
the matching image.

## Install on a VPS

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/QHuy69/outline-server/master/install.sh)" -- --hostname YOUR_SERVER_IP
```

If `wget` is unavailable, the installer itself can use `curl` when invoked from
a downloaded copy:

```bash
curl -fsSL https://raw.githubusercontent.com/QHuy69/outline-server/master/install.sh -o /tmp/outline-install.sh
sudo bash /tmp/outline-install.sh --hostname YOUR_SERVER_IP
```

To pin a release image instead of `latest`:

```bash
sudo SB_IMAGE=ghcr.io/qhuy69/outline-server:v1.0.0 bash -c "$(wget -qO- https://raw.githubusercontent.com/QHuy69/outline-server/master/install.sh)" -- --hostname YOUR_SERVER_IP
```

The GitHub Container Registry package must be public for VPS installations
without `docker login ghcr.io`. After the first successful workflow run, set
the package visibility to Public in the repository’s Packages settings.
