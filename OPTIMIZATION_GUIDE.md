# Container Startup Optimization Guide

This guide explains the optimizations made to speed up container startup times in the Email Phishing Detection SOC Lab.

## 🚀 Optimizations Applied

### 1. Health Check Optimizations
- **Reduced intervals**: From 30s to 10-15s
- **Reduced timeouts**: From 10s to 5-8s  
- **Reduced start periods**: From 60s to 20-30s
- **Optimized health check commands**: Using `-sf` flag for faster curl checks

### 2. Resource Allocation Optimizations
- **Reduced memory limits**: Optimized for actual usage
  - Email server: 2G → 1G
  - Wazuh Indexer: 2G → 1.5G
  - Wazuh Manager: 512M → 384M
  - Wazuh Agent: 256M → 192M
  - Wazuh Dashboard: 512M → 384M

### 3. Dockerfile Optimizations
- **Combined RUN commands**: Reduced layers in Wazuh agent
- **Added .dockerignore files**: Exclude unnecessary files from build context
- **Optimized base images**: Using specific versions
- **Added build environment variables**: `DEBIAN_FRONTEND=noninteractive`
- **Security improvements**: Non-root users

### 4. Startup Script Improvements
- **Reduced wait time**: From 5 minutes to 3 minutes
- **Faster polling**: From 10s to 5s intervals
- **Better progress reporting**: Shows healthy service count
- **Added optimization command**: `./start.sh optimize`
- **Enhanced prerequisites check**: Disk space and memory validation

## 📊 Expected Performance Improvements

| Component | Before | After | Improvement |
|-----------|--------|-------|-------------|
| Health check intervals | 30s | 10-15s | 50-67% faster |
| Start periods | 60s | 20-30s | 50-67% faster |
| Total startup time | ~5-7 min | ~2-3 min | 50-60% faster |
| Memory usage | ~4.5GB | ~3.5GB | 22% reduction |

## 🛠️ Usage

### Quick Optimization
```bash
# Pre-download images and clean up
./start.sh optimize

# Start the environment
./start.sh start
```

### Manual Optimization Steps
```bash
# Clean up Docker resources
docker system prune -f

# Pre-download all images
docker compose pull

# Build with no cache (if needed)
docker compose build --no-cache

# Start services
docker compose up -d
```

## 🔧 Additional Tips

### System-Level Optimizations
1. **Close unnecessary applications** to free up memory
2. **Ensure sufficient disk space** (at least 2GB free)
3. **Use SSD storage** for better I/O performance
4. **Increase Docker memory allocation** in Docker Desktop settings

### Docker-Level Optimizations
1. **Enable BuildKit**: `export DOCKER_BUILDKIT=1`
2. **Use multi-stage builds** for complex applications
3. **Leverage Docker layer caching**
4. **Use `.dockerignore` files** to reduce build context

### Network Optimizations
1. **Use local Docker registry** for frequently used images
2. **Configure Docker DNS** for faster image pulls
3. **Use image compression** for large images

## 📈 Monitoring Startup Performance

### Check Startup Times
```bash
# View container startup logs
docker compose logs --timestamps

# Monitor resource usage
docker stats

# Check health status
docker compose ps
```

### Performance Metrics
- **Container startup time**: Time from `docker compose up` to all services healthy
- **Health check response time**: Time for health checks to pass
- **Memory usage**: Peak memory consumption during startup
- **CPU usage**: Peak CPU consumption during startup

## 🐛 Troubleshooting

### Slow Startup Issues
1. **Check system resources**: `free -h` and `df -h`
2. **Monitor Docker daemon**: `docker system df`
3. **Check for port conflicts**: `netstat -tuln`
4. **Review container logs**: `docker compose logs [service]`

### Common Problems
- **Out of memory**: Reduce memory limits or close other applications
- **Port conflicts**: Stop services using required ports
- **Network issues**: Check Docker network configuration
- **Disk space**: Clean up Docker images and containers

## 🔄 Reverting Changes

If you need to revert to the original configuration:

```bash
# Restore original docker-compose.yml
git checkout HEAD -- docker-compose.yml

# Restore original start.sh
git checkout HEAD -- start.sh

# Clean up and restart
./start.sh cleanup
./start.sh start
```

## 📝 Notes

- These optimizations prioritize startup speed over resource efficiency
- Monitor system performance after applying changes
- Adjust resource limits based on your system capabilities
- Some optimizations may affect security (e.g., reduced health check intervals)
- Test thoroughly in your environment before production use 