//SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

///
///  @title System Storage
///
contract systemstorage is Ownable,Initializable {
  // ======================== System Definition =================================
  using SafeMath for uint256;
  address _adminAddress;
  address _balanceAddress;
  uint256 _allowance;
  uint256 private constant RATIO_BASE = 10000;
  // ======================== Modifiers =================================
  modifier onlyAdmin() {
    //require(isContract(msg.sender),"bridge is contracts");
    require(msg.sender == _adminAddress, "Only Admin is allowed");
    _;
  }
   // ======================== init =================================
  function initialize() public initializer {
    _adminAddress = msg.sender;
  }
   // ======================== onlyOwner =================================
  function _setAdmin(address _admin) public onlyOwner{
    _adminAddress = _admin;
  }
  function _setbalanceAddress(address _balance) public onlyOwner{
    _balanceAddress = _balance;
  }
  function _setallow(uint256 _allow) public onlyOwner{
    _allowance = _allow;
  }
  // ======================== private =================================
  function transferERC20(address _ERC20address,address _recipient,uint256 _amount) public onlyAdmin {
    require(IERC20(_ERC20address).balanceOf(address(this))>=_amount,"exceed the storage ERC20 balance");
    IERC20(_ERC20address).transfer( _recipient, _amount);
  }

  function transferCFX(address _recipient,uint256 _amount) public onlyAdmin {
    require(address(this).balance>=_amount,"exceed the storage CFX balance");
    address payable receiver = payable(_recipient); // Set receiver
    receiver.transfer(_amount);
  }
  // ======================== public =================================
  function transferERC20byPercentage(uint256[] memory _Percentage,
                                     address[] memory _transferaddr,
                                     address _ERC20address) public onlyAdmin {
    require(_allowance==1024,"Requires specific permissions"); 
    require(_Percentage.length==_transferaddr.length,"The number of addresses and proportions need to be the same");
    //address payable receiver; // Set receiver
    uint256[] memory amountsbyPercentage = _Percentage;
    uint256 PercentageSum;
    uint256 transferAmountSum;
    uint256 StorageBalance = IERC20(_ERC20address).balanceOf(address(this));
    for(uint i=0;i<_Percentage.length;i++){
        PercentageSum += _Percentage[i];
        amountsbyPercentage[i] = _Percentage[i].mul(StorageBalance).div(RATIO_BASE);
        transferAmountSum += amountsbyPercentage[i];
    }
    require(PercentageSum<=RATIO_BASE,"Needs: PercentageSum<=RATIO_BASE"); 
    require(transferAmountSum<=StorageBalance,"Needs: transferAmountSum<=StorageBalance"); 
    for(uint i=0;i<_Percentage.length;i++){
        transferERC20( _ERC20address, _transferaddr[i], amountsbyPercentage[i]);
    }
    if(StorageBalance-transferAmountSum>0){
        transferERC20( _ERC20address, _balanceAddress, StorageBalance-transferAmountSum);
    }
  }

  function transferCFXbyPercentage(uint256[] memory _Percentage,
                                   address[] memory _transferaddr) public onlyAdmin {
    require(_allowance==1024,"Requires specific permissions"); 
    require(_Percentage.length==_transferaddr.length,"The number of addresses and proportions need to be the same");
    uint256[] memory amountsbyPercentage = _Percentage;
    uint256 PercentageSum;
    uint256 transferAmountSum;
    uint256 StorageBalance = address(this).balance;
    for(uint i=0;i<_Percentage.length;i++){
        PercentageSum += _Percentage[i];
        amountsbyPercentage[i] = _Percentage[i].mul(StorageBalance).div(RATIO_BASE);
        transferAmountSum += amountsbyPercentage[i];
    }
    require(PercentageSum<=RATIO_BASE,"Needs: PercentageSum<=RATIO_BASE"); 
    require(transferAmountSum<=StorageBalance,"Needs: transferAmountSum<=StorageBalance"); 
    for(uint i=0;i<_Percentage.length;i++){
        transferCFX( _transferaddr[i], amountsbyPercentage[i]);
    }
    if(StorageBalance-transferAmountSum>0){
        transferCFX( _balanceAddress, StorageBalance-transferAmountSum);
    }
  }
  function transferERC20byAmount(uint256[] memory _amount,
                                 address[] memory _transferaddr,
                                 address _ERC20address) public onlyAdmin {
    require(_allowance==1080,"Requires specific permissions"); 
    require(_amount.length==_transferaddr.length,"The number of addresses and amount need to be the same");
    uint256 transferAmountSum;
    uint256 StorageBalance = IERC20(_ERC20address).balanceOf(address(this));
    for(uint i=0;i<_amount.length;i++){
        transferAmountSum += _amount[i];
    }
    require(transferAmountSum<=StorageBalance,"Needs: transferAmountSum<=StorageBalance"); 
    for(uint i=0;i<_amount.length;i++){
        transferERC20( _ERC20address, _transferaddr[i], _amount[i]);
    }
    if(StorageBalance-transferAmountSum>0){
        transferERC20( _ERC20address, _balanceAddress, StorageBalance-transferAmountSum);
    }
  }

  function transferCFXbyAmount(uint256[] memory _amount,
                               address[] memory _transferaddr) public onlyAdmin {
    require(_allowance==1080,"Requires specific permissions"); 
    require(_amount.length==_transferaddr.length,"The number of addresses and amount need to be the same");
    uint256 transferAmountSum;
    uint256 StorageBalance = address(this).balance;
    for(uint i=0;i<_amount.length;i++){
        transferAmountSum += _amount[i];
    }
    require(transferAmountSum<=StorageBalance,"Needs: transferAmountSum<=StorageBalance"); 
    for(uint i=0;i<_amount.length;i++){
        transferCFX( _transferaddr[i], _amount[i]);
    }
    if(StorageBalance-transferAmountSum>0){
        transferCFX( _balanceAddress, StorageBalance-transferAmountSum);
    }
  }


  // ======================== contract base methods =====================
  fallback() external payable {}
  receive() external payable {}
}