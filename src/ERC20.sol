// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IERC20.sol";

/**
 * @title MyERC20
 * @dev 一个简单的 ERC20 代币实现。
 */
contract MyERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public immutable decimals;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @dev 构造函数，在合约部署时执行。
     *      设置代币的名称、符号、小数位数，并铸造初始供应量给部署者。
     * @param initialSupply 初始铸造的代币数量。
     * @param tokenName 代币名称 (例如 "My Token")。
     * @param tokenSymbol 代币符号 (例如 "MTK")。
     * @param tokenDecimals 代币小数位数 (通常是 18)。
     */
    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;

        // 铸造初始供应量给部署者
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev 返回代币的总供应量。
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev 返回指定地址的代币余额。
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev 将 `amount` 数量的代币从调用者账户转移到 `to` 地址。
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        // 要求发送方有足够的余额
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
        // 要求接收方地址不是零地址
        require(to != address(0), "ERC20: transfer to the zero address");

        // 执行转账
        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        // 发出 Transfer 事件
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev 允许 `spender` 从调用者账户中花费 `amount` 数量的代币。
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        // 要求 spender 地址不是零地址
        require(spender != address(0), "ERC20: approve to the zero address");

        // 更新 allowance
        _allowances[msg.sender][spender] = amount;

        // 发出 Approval 事件
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev 返回 `owner` 允许 `spender` 花费的代币数量。
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev 将 `amount` 数量的代币从 `from` 地址转移到 `to` 地址。
     *      此函数只能由已被 `from` 批准（通过 `approve` 函数）的 `spender` 调用。
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        // 要求发送方有足够的余额
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
        // 要求调用者（msg.sender）已被 from 批准有足够的 allowance
        require(_allowances[from][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        // 要求接收方地址不是零地址
        require(to != address(0), "ERC20: transfer to the zero address");
        // 要求发送方地址不是零地址 (虽然通常transferFrom时from不是msg.sender，但作为额外检查)
        require(from != address(0), "ERC20: transfer from the zero address");

        // 减少 from 的余额
        _balances[from] -= amount;
        // 增加 to 的余额
        _balances[to] += amount;
        // 减少调用者（spender）的 allowance
        _approve(from, msg.sender, _allowances[from][msg.sender] - amount); // 使用内部 _approve 更新 allowance

        // 发出 Transfer 事件
        emit Transfer(from, to, amount);
        return true;
    }

    // --- 内部函数 ---

    /**
     * @dev 内部函数：铸造 `amount` 数量的代币并添加到 `account` 的余额中。
     *      此函数不发出 Transfer 事件，因为这不是一个标准的转账行为。
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        // 铸币通常不触发 Transfer 事件，因为没有“from”地址。
        // 如果要遵循ERC20标准，应该触发 from=address(0) 的Transfer事件
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev 内部函数：销毁 `amount` 数量的代币并从 `account` 的余额中移除。
     *      此函数不发出 Transfer 事件。
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");

        _balances[account] -= amount;
        _totalSupply -= amount;
        // 销毁通常不触发 Transfer 事件，因为没有“to”地址。
        // 如果要遵循ERC20标准，应该触发 to=address(0) 的Transfer事件
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev 内部函数：用于更新 `spender` 的 `allowance`。
     *      在 `transferFrom` 中使用，确保 allowance 正确减少。
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
