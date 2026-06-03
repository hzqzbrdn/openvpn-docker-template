# OpenVPN Docker Template

A ready-to-deploy OpenVPN server using Docker, managed via [OpenVPN UI](https://github.com/d3vilh/openvpn-ui). Clone this repo, fill in your values, and have a VPN server running in minutes.

## Features

- OpenVPN over UDP with AES-256-GCM encryption
- Web UI for managing clients (add, revoke, download configs)
- Traefik reverse proxy with HTTPS
- Automatic PKI setup via EasyRSA
- Clean `.gitignore` — certificates and keys are never committed

## Requirements

- A Linux VPS (Ubuntu 22.04+ recommended)
- Docker and Docker Compose installed
- A domain name pointed to your server (for Traefik HTTPS, optional)
- Port 1194/UDP open in your firewall

## Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/openvpn-docker-template.git
cd openvpn-docker-template
```

### 2. Configure your environment

Edit `docker-compose.yml` and replace all placeholder values:

```bash
nano docker-compose.yml
```

Key values to change:
- `YOUR_DOMAIN` → your server domain or IP
- `YOUR_EMAIL` → your email for Traefik SSL
- `YOUR_UI_USERNAME` / `YOUR_UI_PASSWORD` → OpenVPN UI credentials

### 3. Configure EasyRSA variables

```bash
nano config/easy-rsa.vars
```

Set your country, organization, and email.

### 4. Configure server settings

```bash
nano server.conf
```

Adjust subnet, routes, and DNS to match your network.

### 5. Set firewall rules

```bash
nano fw-rules.sh
chmod +x fw-rules.sh
```

### 6. Deploy

```bash
docker compose up -d
```

### 7. Access the UI

Navigate to `http://YOUR_SERVER_IP:8080` (or your domain if Traefik is configured).

Default credentials are set in `docker-compose.yml`.

---

## Adding a Client

1. Log into OpenVPN UI
2. Go to **Clients → Create Client**
3. Enter a name and generate
4. Download the `.ovpn` file and import it into your OpenVPN client

## Revoking a Client

1. Log into OpenVPN UI
2. Go to **Clients → Revoke**
3. The CRL is updated automatically

---

## Directory Structure

```
.
├── config/
│   ├── client.conf         # Client config template
│   └── easy-rsa.vars       # PKI configuration variables
├── .gitignore              # Excludes PKI, client configs, logs
├── Dockerfile
├── docker-compose.yml      # Main stack definition
├── docker-entrypoint.sh    # Container entrypoint
├── entrypoint-wrapper.sh   # Wrapper for entrypoint
├── fw-rules.sh             # Custom firewall rules
└── server.conf             # OpenVPN server configuration
```

---

## Firewall Setup (UFW)

Open required ports on your host:

```bash
sudo ufw allow 1194/udp        # OpenVPN
sudo ufw allow 80/tcp          # Traefik HTTP
sudo ufw allow 443/tcp         # Traefik HTTPS
sudo ufw allow 22/tcp          # SSH
sudo ufw enable
```

---

## Common Commands

### View logs
```bash
docker logs openvpn -f
```

### Check connected clients
```bash
docker exec openvpn cat /var/log/openvpn/openvpn-status.log | grep CLIENT_LIST
```

### Restart OpenVPN
```bash
docker compose restart openvpn
```

### Rebuild after config change
```bash
docker compose down && docker compose up -d
```

---

## ⚠️ Security Notes

- **Never commit the `pki/` directory** — it contains your CA, server certificates, and private keys. The `.gitignore` in this repo excludes it by default.
- Change the default UI credentials immediately after first login.
- Restrict port 2080 (OpenVPN management) to trusted IPs only.
- Use `LIMIT` instead of `ALLOW` for SSH in UFW to prevent brute force.

---

## Troubleshooting

**TLS handshake timeout**
- Check if `max-clients` limit is reached: `docker logs openvpn | grep "maximum number of clients"`
- Verify UDP 1194 is open: check both OS firewall (`ufw status`) and cloud provider firewall

**Client connects but no internet access**
- Ensure `redirect-gateway def1 bypass-dhcp` is uncommented in `server.conf`
- Verify IP forwarding is enabled: `sysctl net.ipv4.ip_forward` (should return `1`)

**Cannot connect to OpenVPN UI**
- Check if the container is running: `docker ps`
- Check UI logs: `docker logs openvpn-ui`

---

## Credits

- [d3vilh/openvpn-server](https://github.com/d3vilh/openvpn-server)
- [d3vilh/openvpn-ui](https://github.com/d3vilh/openvpn-ui)
