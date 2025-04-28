# proxy-poc
## amd64 build
```
docker buildx build -t registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.0_AMD64 --load .
```
## arm64 build
```
docker build -t registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.0_ARM64 --platform linux/arm64 .
```

## manifest list
```
docker manifest create registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.0 registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.0_AMD64 registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.0_ARM64 --amend
Created manifest list registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.0
```

## push manifest list
```
docker manifest push registry.cn-hangzhou.aliyuncs.com/apuer/proxy:0.1.0
```