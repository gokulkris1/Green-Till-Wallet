# Gokul Step 2 - From Zero Infra to Live (Cheapest + Scalable)

You said you have only DNS now. That is fine.

This plan gets you live at low cost, with an easy upgrade path.

---

## 1) Pick the stack (recommended)

### Option A (cheapest now, still scalable later) - **Recommended**
- Backend + MySQL on **one EC2** (`t4g.small`) with Docker Compose
- Receipts on **S3**
- HTTPS via **Nginx + Let's Encrypt**
- Domain: `api.greentill.co`

Estimated monthly (small traffic):
- EC2 + disk: ~`$18-$30`
- S3: ~`$1-$10`
- Total: ~`$20-$40`

### Option B (safer production baseline)
- Backend on EC2
- DB on **RDS MySQL**
- S3 + Nginx + TLS

Estimated monthly:
- EC2 + disk: ~`$18-$30`
- RDS: ~`$25-$50`
- S3: ~`$1-$10`
- Total: ~`$45-$90`

Start with Option A. Move DB to RDS when usage grows.

---

## 2) Create AWS account safely (30 min)

1. Create AWS account.
2. Enable MFA on root account.
3. Create IAM admin user (do not use root daily).
4. Set billing alarm at `$50`.

---

## 3) Create S3 for receipt files (20 min)

1. AWS -> S3 -> Create bucket (example: `greentill-prod-receipts`).
2. Block public access = ON.
3. Enable versioning.
4. Create IAM user for app with S3 access to this bucket only.
5. Save Access Key + Secret (used in backend env).

---

## 4) Create backend server (EC2) (30 min)

1. Launch EC2 `t4g.small` (Ubuntu 22.04).
2. Add security group:
   - `22` (SSH) from your IP
   - `80` and `443` from anywhere
3. Allocate and attach Elastic IP.
4. SSH into server.

Install base tools:
```bash
sudo apt update
sudo apt install -y docker.io docker-compose nginx certbot python3-certbot-nginx
sudo usermod -aG docker ubuntu
```
Log out/in once.

---

## 5) Database setup

### If Option A (cheapest)
Run MySQL in Docker on same EC2.

### If Option B
Create RDS MySQL and allow EC2 security group access.

---

## 6) Deploy backend with env vars (60 min)

Use your backend repo (`/Users/gurijala/Downloads/greentill-backend`) and deploy to EC2.

Required env/config values:
- DB URL / username / password
- S3 bucket + access key + secret
- SMTP username + app password (for signup/forgot)
- Firebase admin key path (if push notifications enabled)

---

## 7) DNS + HTTPS

1. DNS record:
   - Type: `A`
   - Host: `api`
   - Value: `<EC2 Elastic IP>`
2. Nginx reverse proxy `api.greentill.co -> localhost:8080`.
3. Run certbot:
```bash
sudo certbot --nginx -d api.greentill.co
```

---

## 8) Point mobile app to production API

In Flutter repo:
```bash
tools/build_android.sh --release \
  --env=prod \
  --api=https://api.greentill.co \
  --host=api.greentill.co
```

---

## 9) Where each piece is hosted

- **Backend API**: your EC2 server
- **Database**: same EC2 (Option A) or RDS (Option B)
- **Receipt files**: S3
- **Android app**: Google Play
- **iOS app**: App Store

Mobile apps are distributed by stores. Only backend is hosted by you.

---

## 10) Critical security note

Your backend config files currently include real-looking DB/SMTP credentials in plain text.

Do this immediately:
1. Rotate DB password.
2. Rotate SMTP password.
3. Move all secrets to env vars / secret manager.
4. Never commit secrets to git.

---

## 11) Next upgrade path (when users grow)

1. Move MySQL from EC2 -> RDS.
2. Add second EC2 and Load Balancer.
3. Add CI/CD deploy pipeline.
4. Add CloudWatch alerts + automated backups.

This gives low cost now and clean scale later.
