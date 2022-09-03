//SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../VotePowerQueue.sol";
import "./UnstakeQueueCFX.sol";


///
///  @title Exchange room
///
contract systemstorage is Ownable,Initializable {
  address _adminAddress;
  address _balanceAddress;

  // ======================== Modifiers =================================
  modifier onlyAdmin() {
    //require(isContract(msg.sender),"bridge is contracts");
    require(msg.sender == _adminAddress, "Only bridge is allowed");
    _;
  }
   // ======================== init =================================
  function initialize() public initializer {
    _adminAddress = msg.sender;
  }
   // ======================== onlyOwner =================================
  function _setAdmin(address _admin) onlyOwner{
    _adminAddress = _admin;
  }
  function _setbalanceAddress(address _balance) onlyOwner{
    _balanceAddress = _balance;
  }
  // ======================== private =================================
  function transferERC20() private onlyAdmin {

  }

  function transferCFX() private onlyAdmin {

  }

  function transferERC20batch() private onlyAdmin {

  }

  function transferCFXbatch() private onlyAdmin {

  }
  // ======================== public =================================
  function transferERC20byPercentage(uint256 _Percentage,address _ERC20address) private onlyAdmin {

  }
  // ======================== contract base methods =====================
  fallback() external payable {}
  receive() external payable {}
}