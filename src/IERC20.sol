// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title IERC20
 * @dev Required functions for an ERC20 compliant contract.
 */
interface IERC20 {
    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 函数
    /**
     * @dev 返回代币的总供应量。
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev 返回指定地址的代币余额。
     * @param account 要查询余额的地址。
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev 将 `amount` 数量的代币从调用者账户转移到 `to` 地址。
     * @param to 接收方地址。
     * @param amount 要转移的代币数量。
     * @return 成功返回 true。
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev 允许 `spender` 从调用者账户中花费 `amount` 数量的代币。
     *      在调用 `transferFrom` 之前，`spender` 必须先获得调用者的批准。
     * @param spender 被允许花费代币的地址。
     * @param amount 允许花费的代币数量。
     * @return 成功返回 true。
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev 返回 `owner` 允许 `spender` 花费的代币数量。
     * @param owner 拥有代币的地址。
     * @param spender 被允许花费代币的地址。
     * @return 允许花费的代币数量。
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev 将 `amount` 数量的代币从 `from` 地址转移到 `to` 地址。
     *      此函数只能由已被 `from` 批准（通过 `approve` 函数）的 `spender` 调用。
     * @param from 发送方地址。
     * @param to 接收方地址。
     * @param amount 要转移的代币数量。
     * @return 成功返回 true。
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
