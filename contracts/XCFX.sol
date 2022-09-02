//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XCFX is ERC20, Initializable {
    // ======================== configs =========================
    address owner;
    mapping(address=>bool) mainMinter;
    uint256 unlocked=1;
    // ======================== Methods =========================
    modifier onlyMinter() {
        require(mainMinter[msg.sender], "MinterRole: caller does not have the Minter role or above");
        _;
    }
    modifier onlyOwner() {
        require(msg.sender==owner, "Owner Role: caller does not have the Owner role or above");
        _;
    }
    modifier lock() {
        require(unlocked==1, "temp locked, wait a moment");
        unlocked = 0;
        _;
        unlocked = 1;
    }
    // ======================== constructor =========================
    constructor() ERC20("X-nucleon-CFX", "xCFX") {
        owner = msg.sender;
    }
    function initialize() public initializer {
        owner = msg.sender;
    }
    // ======================== Owner function =========================
    function addMinter(address _minter) public onlyOwner(){
        mainMinter[_minter] = true;
    }
    function removeMinter(address _minter) public onlyOwner(){
        mainMinter[_minter] = false;
    }
    // ======================== Minter function =========================
    function addTokens(address _account, uint256 _value) external lock onlyMinter(){
        require(_value>0,"Con't add 0");
        //require( isContract(msg.sender) ,"msg.sender must be a contract");
        _mint(_account, _value);
    }
    function burnTokens(address _account, uint256 _value) external lock onlyMinter(){
        require(_value > 0,"Con't burn 0");
        require(_value <= balanceOf(msg.sender),"Must < account balance");
        //require( isContract(msg.sender) ,"msg.sender must be a contract");
        _burn(_account, _value);
    }
    // ======================== require need function =========================
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.
        return account.code.length > 0;
    }

}

