//SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

contract espaceaddrCFXbalance  {
    function balanceof(address _addr) public returns(uint256) {
        return _addr.balance;
    }
}