// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract nucleon_token is ERC20 {
  address owner;
  mapping(address=>bool) mainMinter;

  constructor(uint256 initialSupply) ERC20("Nucleon Token", "NT") {
    owner = msg.sender;
    _mint(msg.sender, initialSupply);
  }
  modifier onlyOwner() {
        require(msg.sender==owner, "Owner Role: caller does not have the Minter role or above");
        _;
    }
  modifier onlyMinter() {
        require(mainMinter[msg.sender], "MinterRole: caller does not have the Minter role or above");
        _;
    }
  function addMinter(address _minter) public onlyOwner(){
        mainMinter[_minter]=true;
    }
  function removeMinter(address _minter) public onlyOwner(){
        mainMinter[_minter]=false;
    }

  function addTokens(address _to, uint256 _value) external onlyMinter(){
        require(_value>0,"Con't add 0");
        //if (_account_set[_to]==0)  { addAccount(_to); }
        _mint(_to, _value);      
    }
}
