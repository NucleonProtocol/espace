// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TestX is Ownable, Initializable {
    uint256 started;

    function initialize() public initializer {
    }

    function set(uint256 _num) public onlyOwner {
        started = _num;
    }
}