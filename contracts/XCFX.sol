// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface POSPoolExchange{
    function update_after_trans_by_outer_func(address _from,address _to) external;
}

contract XCFX is ERC20 {
    address owner;
    address[]  _account_list ;    //  地址数组

    mapping(address=>uint256) _account_set;   //  地址映射到在地址数组中的编号
    uint256  private del_nums;
    uint256  private all_addr_nums;
    //address public minter;
    address POSPoolAddr;

    mapping(address=>bool) mainMinter;
    uint256 unlocked=1;

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
        unlocked= 0;
        _;
        unlocked= 1;
    }
    constructor(uint256 initialSupply) ERC20("Xespace-CFX", "XCFX") {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    function addMinter(address _minter) public onlyOwner(){
        mainMinter[_minter]=true;
    }
    function removeMinter(address _minter) public onlyOwner(){
        mainMinter[_minter]=false;
    }

    function Set_POSPoolAddr(address _POSPool) public onlyOwner() {
        POSPoolAddr=_POSPool;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        POSPoolExchange(POSPoolAddr).update_after_trans_by_outer_func(msg.sender,recipient);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        POSPoolExchange(POSPoolAddr).update_after_trans_by_outer_func(sender,recipient);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function addTokens(address _to, uint256 _value) external onlyMinter(){
        require(_value>0,"Con't add 0");
        //if (_account_set[_to]==0)  { addAccount(_to); }
        _mint(_to, _value);
        POSPoolExchange(POSPoolAddr).update_after_trans_by_outer_func(_to,_to);
        
    }
    function burnTokenself(uint256 _value) external lock{
        require(_value>0,"Con't burn 0");
        uint balance = balanceOf(msg.sender);
        _burn(msg.sender, _value);
        POSPoolExchange(POSPoolAddr).update_after_trans_by_outer_func(msg.sender,msg.sender);
        //if (balance==_value)  { delAccount(msg.sender); }
    }
    function burnTokens(address _account, uint256 _value) external lock onlyMinter(){
        require(_value>0,"Con't burn 0");
        uint balance = balanceOf(_account);
        _burn(_account, _value);
        POSPoolExchange(POSPoolAddr).update_after_trans_by_outer_func(_account,_account);
        //if (balance==_value)  { delAccount(_account); }
    }

}

