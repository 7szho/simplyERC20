// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ERC20.sol";
import "../src/IERC20.sol";

/**
 * @title ERC20Test
 * @dev Foundry 测试合约，用于测试 MyERC20 合约的功能。
 */
contract ERC20Test is Test {
    MyERC20 public token; // 声明一个 MyERC20 实例，在 setUp 函数中初始化

    // 定义一些测试用的地址
    address public deployer = makeAddr("deployer"); // 合约部署者
    address public user1 = makeAddr("user1"); // 普通用户 1
    address public user2 = makeAddr("user2"); // 普通用户 2
    address public spender = makeAddr("spender"); // 批准者 (spender)

    // 定义常量，例如初始供应量和代币小数位数
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * (10 ** 18); // 1,000,000 个代币，带18位小数
    uint256 public constant DECIMALS = 18;

    /**
     * @dev `setUp` 函数在每个测试函数运行之前执行。
     *      用于初始化测试环境，例如部署合约。
     */
    function setUp() public {
        // 模拟 deployer 部署合约
        vm.startPrank(deployer);
        token = new MyERC20(INITIAL_SUPPLY, "My Test Token", "MTT", uint8(DECIMALS));
        vm.stopPrank();

        // 确认部署者获得了初始供应量
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY);
        console.log("Initial deployer balance:", token.balanceOf(deployer));
    }

    /**
     * @dev 测试代币的名称、符号和小数位数是否正确设置。
     */
    function test_NameSymbolDecimals() public view {
        assertEq(token.name(), "My Test Token", "Name should be 'My Test Token'");
        assertEq(token.symbol(), "MTT", "Symbol should be 'MTT'");
        assertEq(token.decimals(), DECIMALS, "Decimals should be 18");
    }

    /**
     * @dev 测试总供应量和初始部署者余额。
     */
    function test_InitialSupplyAndDeployerBalance() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY, "Total supply should be initial supply");
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY, "Deployer should have initial supply");
        assertEq(token.balanceOf(user1), 0, "User1 should have 0 balance initially");
    }

    /**
     * @dev 测试 `transfer` 函数：正常转账。
     */
    function test_Transfer() public {
        uint256 amountToTransfer = 100 * (10 ** DECIMALS); // 转账 100 个代币

        // 模拟 deployer 发起转账
        vm.startPrank(deployer);
        assertTrue(token.transfer(user1, amountToTransfer), "Transfer should return true");
        vm.stopPrank();

        // 验证余额
        assertEq(
            token.balanceOf(deployer), INITIAL_SUPPLY - amountToTransfer, "Deployer balance incorrect after transfer"
        );
        assertEq(token.balanceOf(user1), amountToTransfer, "User1 balance incorrect after transfer");
    }

    /**
     * @dev 测试 `transfer` 函数：余额不足时转账失败。
     */
    function test_TransferFailsWhenInsufficientBalance() public {
        // user1 初始余额为 0
        vm.startPrank(user1);
        // 期望转账会因为余额不足而回滚
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(user2, 1);
        vm.stopPrank();
    }

    /**
     * @dev 测试 `transfer` 函数：转账到零地址失败。
     */
    function test_TransferFailsToZeroAddress() public {
        vm.startPrank(deployer);
        vm.expectRevert("ERC20: transfer to the zero address");
        token.transfer(address(0), 1);
        vm.stopPrank();
    }

    /**
     * @dev 测试 `approve` 和 `allowance` 函数。
     */
    function test_ApproveAndAllowance() public {
        uint256 approvalAmount = 500 * (10 ** DECIMALS); // 批准 500 个代币

        // 模拟 deployer 批准 spender
        vm.startPrank(deployer);
        assertTrue(token.approve(spender, approvalAmount), "Approve should return true");
        vm.stopPrank();

        // 验证 allowance
        assertEq(token.allowance(deployer, spender), approvalAmount, "Allowance should be correct");
    }

    /**
     * @dev 测试 `transferFrom` 函数：正常转移。
     */
    function test_TransferFrom() public {
        uint256 approvedAmount = 200 * (10 ** DECIMALS); // 批准 200
        uint256 transferFromAmount = 150 * (10 ** DECIMALS); // 实际转移 150

        // 1. 部署者批准 spender
        vm.startPrank(deployer);
        token.approve(spender, approvedAmount);
        vm.stopPrank();

        // 2. spender 从部署者账户转移到 user1
        vm.startPrank(spender);
        assertTrue(token.transferFrom(deployer, user1, transferFromAmount), "transferFrom should return true");
        vm.stopPrank();

        // 验证余额和 allowance
        assertEq(
            token.balanceOf(deployer),
            INITIAL_SUPPLY - transferFromAmount,
            "Deployer balance incorrect after transferFrom"
        );
        assertEq(token.balanceOf(user1), transferFromAmount, "User1 balance incorrect after transferFrom");
        assertEq(
            token.allowance(deployer, spender),
            approvedAmount - transferFromAmount,
            "Allowance should be reduced correctly"
        );
    }

    /**
     * @dev 测试 `transferFrom` 函数：批准额度不足时失败。
     */
    function test_TransferFromFailsInsufficientAllowance() public {
        uint256 approvedAmount = 50 * (10 ** DECIMALS); // 批准 50
        uint256 transferFromAmount = 100 * (10 ** DECIMALS); // 尝试转移 100

        // 1. 部署者批准 spender
        vm.startPrank(deployer);
        token.approve(spender, approvedAmount);
        vm.stopPrank();

        // 2. spender 尝试从部署者账户转移，期望失败
        vm.startPrank(spender);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        token.transferFrom(deployer, user1, transferFromAmount);
        vm.stopPrank();
    }

    /**
     * @dev 测试 `transferFrom` 函数：发送方余额不足时失败。
     */
    function test_TransferFromFailsInsufficientBalance() public {
        uint256 approvedAmount = 100 * (10 ** DECIMALS);
        uint256 transferFromAmount = 100 * (10 ** DECIMALS);

        // user1 只有 0 余额
        vm.startPrank(deployer);
        // 部署者批准 spender 从 user1 账户转移（尽管user1没钱）
        // 这里只是为了演示，实际情况不会这样批准
        token.approve(spender, approvedAmount);
        vm.stopPrank();

        // spender 尝试从 user1 账户转移，期望因为 user1 余额不足而失败
        vm.startPrank(spender);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transferFrom(user1, user2, transferFromAmount);
        vm.stopPrank();
    }

    /**
     * @dev 测试 `_mint` 内部函数（通过构造函数调用）。
     */
    function test_MintEventOnDeployment() public {
        // 期望在部署时触发一个 Transfer 事件，from 为零地址
        // vm.expectEmit(true, true, true, true); // (from, to, value, data) - 匹配所有
        // console.logAddress(address(0)); // 调试输出零地址

        vm.expectEmit(true, true, false, true); // from, to, value, data (data是abi编码的)
        emit IERC20.Transfer(address(0), deployer, INITIAL_SUPPLY);

        // 重新部署合约以捕获事件
        vm.startPrank(deployer);
        new MyERC20(INITIAL_SUPPLY, "My Test Token", "MTT", uint8(DECIMALS));
        vm.stopPrank();
    }

    // 可以在这里添加更多的测试，例如测试对零地址的批准、重复批准等边界情况。
}
