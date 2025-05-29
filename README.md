# proxy-poc
## amd64 build
```
docker buildx build -t registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.1_AMD64 --load .
docker push registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.1_AMD64
```
## arm64 build
```
docker buildx build -t registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.1_ARM64 --platform linux/arm64 .
docker push registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.1_ARM64
```

## manifest list
```
# 必须想将相关镜像push到仓库才能创建manifest
docker manifest create registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.1 registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.1_AMD64 \
registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.1_ARM64 --amend
```

## push manifest list
```
docker manifest push registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.1
```