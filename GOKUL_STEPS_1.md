# Gokul Step 1 - Domain + Hosting (Cheapest Scalable Setup)

## What you already have
- Domain: `greentill.co`
- Working staging API host: `https://greentill-api.apps.openxcell.dev`
- Flutter app configured to switch API by build flag (`GT_API_BASE_URL`)

## Part A - Create `api.greentill.co` (no new domain needed)

1. Open your DNS provider panel for `greentill.co` (NS1/IBM NS1 Connect).
2. Add this DNS record:
   - Type: `CNAME`
   - Name/Host: `api`
   - Value/Target: `greentill-api.apps.openxcell.dev`
   - TTL: `300` (or default)
3. Save.
4. Verify from terminal:
   - `dig +short api.greentill.co`
   - `curl -I https://api.greentill.co/api/user/login`

If DNS is correct, `dig` returns a value and `curl` returns HTTP status (not DNS error).

---

## Part B - Cheapest but scalable hosting choice

### Recommended now (lowest cost + simple)
- **API app**: 1 AWS EC2 instance (`t4g.small`, Ubuntu 22.04) with Docker
- **Database**: your existing AWS RDS MySQL
- **Files**: your existing S3 bucket
- **TLS/SSL**: Nginx + Let's Encrypt

This is the cheapest serious production setup and can be scaled later.

---

## Part C - Exact setup steps (beginner friendly)

### 1) Create EC2
1. AWS Console -> EC2 -> Launch Instance
2. Name: `greentill-api-prod`
3. AMI: Ubuntu 22.04 LTS
4. Type: `t4g.small`
5. Create key pair (`.pem`) and download
6. Security Group inbound:
   - SSH `22` from your IP
   - HTTP `80` from Anywhere
   - HTTPS `443` from Anywhere
7. Launch

### 2) Attach fixed IP
1. EC2 -> Elastic IPs -> Allocate
2. Associate it with `greentill-api-prod`

### 3) Point domain to server
In DNS (NS1), change/add:
- Type: `A`
- Host: `api`
- Value: `<your Elastic IP>`

### 4) SSH into server
```bash
ssh -i /path/to/your-key.pem ubuntu@<your-elastic-ip>
```

### 5) Install Docker + Nginx + Certbot
```bash
sudo apt update
sudo apt install -y docker.io docker-compose nginx certbot python3-certbot-nginx
sudo usermod -aG docker ubuntu
```
Log out/in once after usermod.

### 6) Deploy backend container
```bash
mkdir -p /opt/greentill && cd /opt/greentill
git clone <your-backend-repo-url> backend
cd backend
docker build -t greentill-api .
```

Create env file:
```bash
cat > /opt/greentill/.env << 'EOF'
SPRING_PROFILES_ACTIVE=master
SPRING_DATASOURCE_URL=jdbc:mysql://<rds-host>:3306/<db-name>
SPRING_DATASOURCE_USERNAME=<db-user>
SPRING_DATASOURCE_PASSWORD=<db-password>
SPRING_MAIL_HOST=<smtp-host>
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=<smtp-user>
SPRING_MAIL_PASSWORD=<smtp-password>
EOF
```

Run container:
```bash
docker run -d --name greentill-api --restart unless-stopped \
  --env-file /opt/greentill/.env \
  -p 8080:8080 greentill-api
```

### 7) Configure Nginx reverse proxy
Create `/etc/nginx/sites-available/greentill-api`:
```nginx
server {
    server_name api.greentill.co;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable:
```bash
sudo ln -s /etc/nginx/sites-available/greentill-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 8) Enable HTTPS certificate
```bash
sudo certbot --nginx -d api.greentill.co
```

---

## Part D - Wire app build to production API

From Flutter repo:
```bash
tools/build_android.sh --release \
  --env=prod \
  --api=https://api.greentill.co \
  --host=api.greentill.co
```

---

## Part E - Where mobile apps are hosted
- **Android app**: Google Play Store
- **iOS app**: Apple App Store
- Your backend server only powers app APIs; mobile binaries are distributed by stores.

---

## Part F - Scale later (no rebuild needed)
1. Vertical scale first: `t4g.small -> t4g.medium`
2. Add second EC2 behind AWS Load Balancer
3. Move to ECS/Fargate only when traffic is high

This path keeps cost low now and stays production-safe.
