# ContextKit Deployment Guide

This guide covers deploying all components of ContextKit to production.

## Table of Contents

1. [Backend (Cloudflare Workers)](#backend-deployment)
2. [Dashboard (Vercel)](#dashboard-deployment)
3. [SDK Distribution](#sdk-distribution)
4. [Database Setup](#database-setup)
5. [DNS Configuration](#dns-configuration)
6. [Monitoring](#monitoring)

---

## Backend Deployment

### Prerequisites

- Cloudflare account
- Wrangler CLI installed: `npm install -g wrangler`
- Git repository set up

### Step 1: Initialize D1 Database

```bash
cd backend

# Create D1 database
wrangler d1 create contextkit

# Note the database_id from output, update wrangler.toml
```

Update `wrangler.toml` with your database ID:

```toml
[[d1_databases]]
binding = "DB"
database_name = "contextkit"
database_id = "your-database-id-here"
```

### Step 2: Run Database Migrations

```bash
# Initialize schema
wrangler d1 execute contextkit --file=./schema/schema.sql

# Verify tables created
wrangler d1 execute contextkit --command="SELECT name FROM sqlite_master WHERE type='table';"
```

### Step 3: Deploy Worker

```bash
# Install dependencies
npm install

# Deploy to production
wrangler deploy

# Deploy to staging
wrangler deploy --env development
```

### Step 4: Configure Custom Domain

In Cloudflare Dashboard:

1. Go to Workers & Pages
2. Select your worker
3. Settings → Triggers → Custom Domains
4. Add: `api.contextkit.dev`

### Step 5: Set Environment Variables (if needed)

```bash
# Set secrets
wrangler secret put STRIPE_API_KEY
wrangler secret put CLAUDE_API_KEY  # For Phase 2 AI features
```

### Verify Deployment

```bash
# Test health endpoint
curl https://api.contextkit.dev/v1/health

# Should return: {"status":"ok","timestamp":...}
```

---

## Dashboard Deployment

### Prerequisites

- Vercel account
- Vercel CLI installed: `npm install -g vercel`

### Step 1: Configure Environment Variables

Create `.env.local`:

```bash
NEXT_PUBLIC_API_URL=https://api.contextkit.dev/v1
NEXT_PUBLIC_STRIPE_PUBLIC_KEY=pk_live_...
CLERK_SECRET_KEY=sk_...
```

### Step 2: Deploy to Vercel

```bash
cd dashboard

# Install dependencies
npm install

# Build locally to test
npm run build

# Deploy to production
vercel --prod

# Or connect GitHub repo for automatic deployments
```

### Step 3: Configure Custom Domain

In Vercel Dashboard:

1. Project Settings → Domains
2. Add `contextkit.dev`
3. Add `www.contextkit.dev`
4. Configure DNS (see below)

### Verify Deployment

Visit `https://contextkit.dev` and verify:
- Landing page loads
- Dashboard is accessible
- API calls work

---

## SDK Distribution

### Step 1: Tag Release

```bash
cd ContextKit

# Create git tag
git tag -a 1.0.0 -m "Release version 1.0.0"
git push origin 1.0.0
```

### Step 2: Create GitHub Release

1. Go to GitHub → Releases → New Release
2. Choose tag: `1.0.0`
3. Title: `ContextKit 1.0.0`
4. Description: Include changelog
5. Attach:
   - `ContextKit.zip` (Swift Package)
   - `CHANGELOG.md`

### Step 3: Verify Swift Package

```bash
# Test SPM installation
swift package resolve
swift build
swift test
```

### Step 4: Update Package Index (Optional)

Submit to Swift Package Index:
1. Go to https://swiftpackageindex.com
2. Add package: `https://github.com/contextkit/contextkit`

---

## Database Setup

### Development Database

```bash
# Local D1 database for development
wrangler d1 create contextkit-dev
wrangler d1 execute contextkit-dev --file=./schema/schema.sql
```

### Production Database

```bash
# Create production database
wrangler d1 create contextkit-prod
wrangler d1 execute contextkit-prod --file=./schema/schema.sql

# Backup database (run daily)
wrangler d1 export contextkit-prod --output=backup-$(date +%Y%m%d).sql
```

### Database Maintenance

```bash
# View database size
wrangler d1 execute contextkit-prod --command="SELECT
  COUNT(*) as total_events,
  COUNT(DISTINCT app_id) as total_apps
FROM events;"

# Clean old events (optional - keep last 90 days)
wrangler d1 execute contextkit-prod --command="DELETE FROM events
WHERE timestamp < strftime('%s', 'now', '-90 days');"
```

---

## DNS Configuration

### Cloudflare DNS Settings

**api.contextkit.dev** (Worker)
```
Type: CNAME
Name: api
Target: your-worker.workers.dev
Proxy: Enabled (orange cloud)
```

**contextkit.dev** (Vercel)
```
Type: A
Name: @
Target: 76.76.21.21 (Vercel IP)

Type: CNAME
Name: www
Target: cname.vercel-dns.com
```

**docs.contextkit.dev** (Documentation)
```
Type: CNAME
Name: docs
Target: your-docs-site.vercel.app
```

### SSL/TLS Settings

- SSL/TLS mode: Full (strict)
- Always Use HTTPS: On
- Automatic HTTPS Rewrites: On
- Minimum TLS Version: 1.2

---

## Monitoring

### Cloudflare Workers Analytics

Monitor in Cloudflare Dashboard:
- Requests per second
- Error rate
- P50/P95/P99 latency
- CPU usage

### Vercel Analytics

Monitor in Vercel Dashboard:
- Page views
- Unique visitors
- Performance metrics
- Error tracking

### Custom Monitoring (Optional)

Set up alerts for:

```bash
# High error rate
wrangler tail --format=pretty | grep -i error

# Database size
wrangler d1 execute contextkit-prod --command="SELECT
  (page_count * page_size) / 1024 / 1024 as size_mb
FROM pragma_page_count(), pragma_page_size();"
```

### Uptime Monitoring

Use a service like:
- Better Uptime
- UptimeRobot
- Pingdom

Monitor endpoints:
- `https://api.contextkit.dev/v1/health`
- `https://contextkit.dev`

---

## Rollback Procedures

### Backend Rollback

```bash
# List deployments
wrangler deployments list

# Rollback to specific deployment
wrangler rollback --version=<deployment-id>
```

### Dashboard Rollback

In Vercel Dashboard:
1. Deployments
2. Find previous successful deployment
3. Click "⋯" → Promote to Production

### Database Rollback

```bash
# Restore from backup
wrangler d1 execute contextkit-prod --file=backup-20260215.sql
```

---

## Security Checklist

- [ ] API keys rotated
- [ ] Rate limiting enabled
- [ ] CORS properly configured
- [ ] Secrets not in git
- [ ] SSL/TLS configured
- [ ] Database backups automated
- [ ] Error messages don't leak sensitive data
- [ ] GDPR compliance checked
- [ ] Privacy policy updated

---

## Performance Optimization

### Backend

- [ ] Enable Cloudflare caching for GET endpoints
- [ ] Use D1 prepared statements
- [ ] Batch database operations
- [ ] Add indexes to frequently queried columns

### Dashboard

- [ ] Enable Vercel Edge caching
- [ ] Optimize images with Next.js Image
- [ ] Use React Server Components
- [ ] Code splitting for large components

### SDK

- [ ] Minimize SDK binary size
- [ ] Batch event uploads
- [ ] Use compression for payloads
- [ ] Cache context snapshots when possible

---

## Cost Estimation

### Cloudflare Workers (Free Tier)

- 100K requests/day: FREE
- 1M requests/day: ~$0.15/day ($4.50/month)
- 10M requests/day: ~$1.50/day ($45/month)

### D1 Database (Alpha - Currently Free)

- First 5 GB storage: FREE
- First 1M reads/day: FREE
- First 100K writes/day: FREE

### Vercel (Hobby Tier)

- Bandwidth: 100 GB/month FREE
- Serverless Functions: 100 GB-hours/month FREE
- Build time: 6000 minutes/month FREE

**Total estimated cost for 10K events/day: ~$5-10/month**

---

## CI/CD Pipeline (Optional)

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          workingDirectory: backend

  deploy-dashboard:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: vercel/actions@v1
        with:
          token: ${{ secrets.VERCEL_TOKEN }}
```

---

## Support

For deployment issues:

- 📧 Email: support@contextkit.dev
- 💬 Discord: discord.gg/contextkit
- 📚 Docs: docs.contextkit.dev

---

**Deployment complete! 🚀**
