// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ERC20.sol";
/**
 * @title MyERC20Script
 * @dev Foundry 部署脚本，用于部署 MyERC20 合约。
 */
contract MyERC20Script is Script {
    // 定义代币参数
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * (10 ** 18); // 1,000,000 个代币
    string public constant TOKEN_NAME = "My Sample Token";
    string public constant TOKEN_SYMBOL = "MST";
    uint8 public constant TOKEN_DECIMALS = 18;

    /**
     * @dev `run` 函数是脚本的入口点。
     *      它返回一个 uint256 值，通常是部署的合约地址。
     */
    function run() public returns (address payable myERC20ContractAddress) {
        // 加载私钥。
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY"); // 从环境变量获取私钥

        // `vm.startBroadcast()` 允许后续的交易被广播到链上。
        // 传入私钥，Foundry 会用它来签名交易。
        vm.startBroadcast(deployerPrivateKey);

        // 部署 MyERC20 合约
        MyERC20 myERC20 = new MyERC20(
            INITIAL_SUPPLY,
            TOKEN_NAME,
            TOKEN_SYMBOL,
            TOKEN_DECIMALS
        );

        // 停止广播
        vm.stopBroadcast();

        // 打印部署信息
        console.log("MyERC20 contract deployed to:", address(myERC20));
        console.log("Token Name:", myERC20.name());
        console.log("Token Symbol:", myERC20.symbol());
        console.log("Total Supply:", myERC20.totalSupply());

        // 返回部署的合约地址
        myERC20ContractAddress = payable(address(myERC20));
    }
}