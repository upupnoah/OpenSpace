# Makefile

# 定义默认目标，不对应实际文件
.PHONY: deploy_transport deploy_uups

# 读取.env文件中的所有变量并导出
include .env
export $(shell sed 's/=.*//' .env)

# 执行部署脚本, 执行会报错, 请直接复制出去使用
deploy_transport:
	forge script ./script/DeployTransportProxy.s.sol --rpc-url sepolia --private-key ${PRIVATE_KEY} --broadcast --verify --sender 0x3Dc121cA82697cB8C2C9D2b151bB6002316eC5A9 --force

deploy_uups:
	forge script ./script/DeployUUPSProxy.s.sol --rpc-url sepolia --private-key ${PRIVATE_KEY} --broadcast --verify --sender 0x3Dc121cA82697cB8C2C9D2b151bB6002316eC5A9 --force

upgrade:
	forge script ./script/UpgradeNFTMarket.s.sol --rpc-url sepolia --private-key ${PRIVATE_KEY} --broadcast --verify --sender 0x3Dc121cA82697cB8C2C9D2b151bB6002316eC5A9 --force