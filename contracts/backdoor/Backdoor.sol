// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";

contract Backdoor {
    address[] targets;
    address owner;
    GnosisSafeProxyFactory factory;
    address registry;
    address token;

    constructor(address[] calldata _targets, address _registry, address _factory, address _token) {
        targets = _targets;
        factory = _factory;
        token = _token;
        registry = _registry;
        owner = msg.sender;
    }

    function attack() external {
        for (uint8 i = 0; i < targets.length; i++) {


        }
    }

}