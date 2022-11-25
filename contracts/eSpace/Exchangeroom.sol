//SPDX-License-Identifier: BUSL-1.1
// Licensor:            X-Dao.
// Licensed Work:       NUCLEON 1.0

pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../VotePowerQueue.sol";

interface IXCFX{
    function addTokens(address _account, uint256 _value) external;
    function burnTokens(address _account, uint256 _value) external;
    function balanceOf(address _account) external view returns(uint256);
    function totalSupply() external view returns(uint256);
}

///
///  @title Exchange room
///  @notice Users use this contract to participate Conflux PoS stake.
///
contract Exchangeroom is Ownable,Initializable {
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AddressSet;
  using VotePowerQueue for VotePowerQueue.InOutQueue;

  uint256 private constant ONE_DAY_BLOCK_COUNT = 3600 * 24; // 86400
  
  // ======================== Pool config ===============================
  // wheter this poolContract registed in PoS
  string private poolName; // = "UNCLEON HUB";
  bool public birdgeAddrSetted;
  address private _bridgeAddress;
  address private _CoreExchange;
  uint256 private _minexchangelimits;
  uint256 private _unstakeCFXs;
  // lock period: 15 days or 2 days
  uint256 private _poolLockPeriod_slow ; //= ONE_DAY_BLOCK_COUNT * 15; 1296000
  uint256 private _poolLockPeriod_fast;  // = ONE_DAY_BLOCK_COUNT * 2; 172800
  
   // ======================== xCFX use ==================================
  address private xCFX_address;
  address private Storage_addr;
  // ======================== Struct definitions =========================
  /// @title ExchangeSummary
  /// @custom:field totalxcfxs
  /// @custom:field xcfxvalues
  /// @custom:field alloflockedvotes
  /// @custom:field xCFXincrease
  /// @custom:field unlockingCFX
  struct ExchangeSummary {
    uint256 totalxcfxs;
    uint256 xcfxvalues;
    uint256 alloflockedvotes;
    uint256 xCFXincrease;
    uint256 unlockingCFX;
  }
  /// @title UserSummary
  /// @custom:field unlocking
  /// @custom:field unlocked
  struct UserSummary {
    uint256 unlocking;
    uint256 unlocked;
  }
  // ======================== Contract states ===========================
  ExchangeSummary private _exchangeSummary;
  mapping(address => UserSummary) private userSummaries;
  VotePowerQueue.InOutQueue private Inqueues;
  mapping(address => VotePowerQueue.InOutQueue) private userOutqueues;
  // ======================== Modifiers =================================
  modifier onlyRegisted() {
    require(birdgeAddrSetted, "Pool is not setted");
    _;
  }
  modifier onlyBridge() {
    require(msg.sender == _bridgeAddress||msg.sender == _CoreExchange, "Only bridge is allowed");
    _;
  }

  // ======================== Events ====================================

  event IncreasePoSStake(address indexed user, uint256 votePower);

  event DecreasePoSStake(address indexed user, uint256 votePower);

  event WithdrawStake(address indexed user, uint256 votePower);

  event SetLockPeriod(address indexed user, uint256 slow, uint256 fast);

  event Setminexchangelimits(address indexed user, uint256 _min);

  event SetPoolName(address indexed user, string name);

  event SetBridge(address indexed user, address bridgeAddress);

  event SetCoreExchange(address indexed user, address addr);

  event SetStorageaddr(address indexed user, address s_addr);

  event SetstorageBridge(address indexed user, address s_addr);

  event SetXCFXaddr(address indexed user, address xcfx_addr);

  event HandleCFXexchangeXCFX(address indexed user);

  event HandlexCFXadd(address indexed user, uint256 amount);

  event HandleUnstake(address indexed user, uint256 amount);

  event SetxCFXValue(address indexed user, uint256 cfxvalue);

  event Setlockedvotes(address indexed user, uint256 lockedvotes);

  // ======================== Init methods ==============================

  // call this method when depoly the 1967 proxy contract
  function initialize(address _XCFXaddress,uint256 xCFXamountInit) public payable initializer {
    require(xCFXamountInit==msg.value,'xCFXamountInit should be equal to msg.value');
    require(_XCFXaddress!=address(0x0000000000000000000000000000000000000000),'Can not be Zero adress');
    poolName = "UNCLEON HUB eSpace";
    _minexchangelimits = 1 ether;
    _exchangeSummary.xcfxvalues = 1 ether;
    _poolLockPeriod_slow = ONE_DAY_BLOCK_COUNT * 15;
    _poolLockPeriod_fast = ONE_DAY_BLOCK_COUNT * 2;
    xCFX_address = _XCFXaddress;
    _exchangeSummary.totalxcfxs = xCFXamountInit;
    _exchangeSummary.xCFXincrease = xCFXamountInit;
    IXCFX(xCFX_address).addTokens(msg.sender, xCFXamountInit);
  }
  // ======================== Contract methods =========================
  // @title CFX_exchange_estim
  // @dev _amount The amount of CFX to stake
  // return xCFX numbers can get
  //
  function CFX_exchange_estim(uint256 _amount) public view returns(uint256){
    return _amount.mul(1 ether).div(_exchangeSummary.xcfxvalues);
    }
  //
  // @title CFX_exchange_XCFX
  // @dev msg.value The amount of CFX to stake
  // emit IncreasePoSStake(msg.sender, msg.value);
  //
  function CFX_exchange_XCFX() external payable returns(uint256){
    require(msg.value >= _minexchangelimits, "Min msg.value is minexchangelimits");
    _exchangeSummary.totalxcfxs = IXCFX(xCFX_address).totalSupply();
    collectOutqueuesFinishedVotes();
    uint256 xcfx_exchange = CFX_exchange_estim(msg.value);

    _exchangeSummary.totalxcfxs += xcfx_exchange;
    _exchangeSummary.xCFXincrease += xcfx_exchange;
    address payable receiver = payable(_bridgeAddress);
    (bool success, ) = receiver.call{value:msg.value}("");
    require(success,"CFX Transfer Failed");

    IXCFX(xCFX_address).addTokens(msg.sender, xcfx_exchange);
    emit IncreasePoSStake(msg.sender, msg.value);
    return xcfx_exchange;
  }
  //
  // @title XCFX_burn_estim
  // @dev estimate The amount of CFX to user when user burn a _amount xCFX
  // return CFX amounts user can get
  //
  function XCFX_burn_estim(uint256 _amount) public view returns(uint256,uint256){
    uint256 cfx_back = _amount.mul(_exchangeSummary.xcfxvalues).div(1 ether);
    uint256 mode = 0;  //default slow mode
    if(cfx_back<=_exchangeSummary.alloflockedvotes.mul(1000 ether)){
      mode = 1;  //set fast mode
    }
    return (cfx_back,mode);
    }
  //
  // @title XCFX_burn
  // @dev burn  _amount  XCFX to get CFXstake
  // emit DecreasePoSStake(msg.sender, _amount);
  //
  function XCFX_burn(uint256 _amount) public virtual onlyRegisted returns(uint256, uint256){
    require(_amount >= _minexchangelimits,"Min amount is minexchangelimits");
    require(_amount <= IXCFX(xCFX_address).balanceOf(msg.sender),"Exceed your xCFX balance");
    _exchangeSummary.totalxcfxs = IXCFX(xCFX_address).totalSupply();
    uint256 _mode = 0;
    uint256 cfx_back;
    uint256 speedMode;
    (cfx_back,_mode) = XCFX_burn_estim(_amount);
    require(_amount<=_exchangeSummary.totalxcfxs,"Exceed exchange limit");
    
    _exchangeSummary.totalxcfxs -= _amount;
    _exchangeSummary.unlockingCFX += cfx_back;
    
    if(_mode == 1){
      userOutqueues[msg.sender].enqueue(VotePowerQueue.QueueNode(_amount, cfx_back, block.number + _poolLockPeriod_fast));
      speedMode = 101109; //fast code
      }
    else{
      userOutqueues[msg.sender].enqueue(VotePowerQueue.QueueNode(_amount, cfx_back, block.number + _poolLockPeriod_slow));
      speedMode = 100001; //slow code
    }
    
    userSummaries[msg.sender].unlocking += cfx_back;

    collectOutqueuesFinishedVotes() ;
    require(userOutqueues[msg.sender].queueLength()<36,"TOO long queues!");
    _unstakeCFXs += cfx_back;
    IXCFX(xCFX_address).burnTokens(msg.sender, _amount);
    emit DecreasePoSStake(msg.sender, cfx_back);
    return (cfx_back, speedMode);
  }
  //
  // @title getback_CFX
  // @dev after cooldown time is over, user get his CFX 
  //  _amount is the CFX amount
  //
  function getback_CFX(uint256 _amount) public virtual onlyRegisted {
     withdraw(_amount);
  }

  //
  // @notice Withdraw CFX
  // @param _amount The amount of CFX to withdraw
  //
  function withdraw(uint256 _amount) private {
    require(address(this).balance>=_amount,"pool Unlocked CFX is not enough");

    collectOutqueuesFinishedVotes() ;
    require(userSummaries[msg.sender].unlocked >= _amount, "your Unlocked CFX is not enough");
    _exchangeSummary.unlockingCFX -= _amount;
    
    userSummaries[msg.sender].unlocked -= _amount;
    address payable receiver = payable(msg.sender);
    (bool success, ) = receiver.call{value: _amount}("");
    require(success,"CFX Transfer Failed");
    emit WithdrawStake(msg.sender, _amount);
  }

  function collectOutqueuesFinishedVotes() public {
    uint256 temp_amount = userOutqueues[msg.sender].collectEndedVotes();
    userSummaries[msg.sender].unlocked += temp_amount;
    userSummaries[msg.sender].unlocking -= temp_amount;
  }

  // 
  // @notice Get user's pool summary
  // @param _user The address of user to query
  // @return User's summary
  //
  function userSummary(address _user) public view returns (UserSummary memory) {
    UserSummary memory summary = userSummaries[_user];
    uint256 temp_amount =userOutqueues[_user].sumEndedVotes();
    summary.unlocked += temp_amount;
    summary.unlocking -= temp_amount;
    return summary;
  }
  // @title Summary() 
  // @dev get the pos pool Summary
  function Summary() public view returns (ExchangeSummary memory) {
    return _exchangeSummary;
  }
  // @title userOutQueue(address account)
  // @dev get the user's OutQueue
  function userOutQueue(address account) public view returns (VotePowerQueue.QueueNode[] memory) {
    return userOutqueues[account].queueItems();
  }
  // @title getBridge() 
  // @dev get the bridgeAddress;
  function getBridge() public view returns(address){
    return _bridgeAddress;
  }
  // ======================== admin methods =============================
  // Set the exchange paramters by admin
  // 1 LockPeriod
  // 2 _minexchangelimits
  // 3 PoolName
  // 4 _bridgeAddress
  // 5 _CoreExchange
  // 6 Storage_addr
  // 7 xCFX_address
  //
  function _setLockPeriod(uint256 slow,uint256 fast) public onlyOwner {
    _poolLockPeriod_slow = slow;
    _poolLockPeriod_fast = fast;
    emit SetLockPeriod(msg.sender, slow, fast);
  }
  function _setminexchangelimits(uint256 minlimits) external onlyOwner {
    _minexchangelimits = minlimits;
    emit Setminexchangelimits(msg.sender, minlimits);
  }
  function _setPoolName(string memory name) public onlyOwner {
    poolName = name;
    emit SetPoolName(msg.sender, name);
  }
  function _setBridge(address bridgeAddress) public onlyOwner {
    require(bridgeAddress!=address(0x0000000000000000000000000000000000000000),'Can not be Zero adress');
    _bridgeAddress = bridgeAddress;
    birdgeAddrSetted = true;
    emit SetBridge(msg.sender, bridgeAddress);
  }
  function _setCoreExchange(address coreExchangeaddr) external onlyOwner {
    require(coreExchangeaddr!=address(0x0000000000000000000000000000000000000000),'Can not be Zero adress');
    _CoreExchange = coreExchangeaddr;
    emit SetCoreExchange(msg.sender, coreExchangeaddr);
  }
  function _setstorageBridge(address storageBridgeaddr) external onlyOwner {
    require(storageBridgeaddr!=address(0x0000000000000000000000000000000000000000),'Can not be Zero adress');
    storageBridge = storageBridgeaddr;
    emit SetstorageBridge(msg.sender, storageBridge);
  }
  function _setStorageaddr(address storageaddr) external onlyOwner {
    require(storageaddr!=address(0x0000000000000000000000000000000000000000),'Can not be Zero adress');
    Storage_addr = storageaddr;
    emit SetStorageaddr(msg.sender, storageaddr);
  }  
  function _setXCFXaddr(address xCFXaddr) external onlyOwner {
    require(xCFXaddr!=address(0x0000000000000000000000000000000000000000),'Can not be Zero adress');
    xCFX_address = xCFXaddr;
    emit SetXCFXaddr(msg.sender, xCFXaddr);
  } 
  // Get LockPeriod 
  function getLockPeriod() external view returns(uint256,uint256){
    return (_poolLockPeriod_slow, _poolLockPeriod_fast);
  }
  // Get Settings 
  function getSettings() external view returns(string memory name,address,address,address,address,address){
    return (poolName,_bridgeAddress,_CoreExchange,storageBridge,Storage_addr,xCFX_address);
  }
  // ==================== cross space bridge methods ====================
  // methods that the core bridge use
  function handleCFXexchangeXCFX() external payable onlyBridge returns(uint256){
    require(msg.value>0 , 'must > 0');
    _exchangeSummary.totalxcfxs = IXCFX(xCFX_address).totalSupply();

    uint256 xcfx_exchange = CFX_exchange_estim(msg.value);
    
    _exchangeSummary.totalxcfxs += xcfx_exchange;
    _exchangeSummary.xCFXincrease += xcfx_exchange;

    address payable receiver = payable(_bridgeAddress);
    (bool success, ) = receiver.call{value:msg.value}("");
    require(success,"CFX Transfer Failed");
    if(msg.sender == _CoreExchange){
      IXCFX(xCFX_address).addTokens(storageBridge, xcfx_exchange);
      emit IncreasePoSStake(storageBridge, msg.value);
    }
    else{
      IXCFX(xCFX_address).addTokens(Storage_addr, xcfx_exchange);
      emit IncreasePoSStake(Storage_addr, msg.value);
    }

    emit HandleCFXexchangeXCFX(msg.sender);
    return xcfx_exchange;
  }
  //let bridge know the xCFX increased in this exchangeroom , and set the para::xCFXincrease to 0 
  function handlexCFXadd() public onlyBridge returns(uint256 ){
    uint256 temp_stake = _exchangeSummary.xCFXincrease ;
    _exchangeSummary.xCFXincrease = 0;
    emit HandlexCFXadd(msg.sender, temp_stake);
    return temp_stake;
  }
  //let bridge know the  CFX need to get back, and set the para::unlockingCFX to 0 
  function handleUnstake() public onlyBridge returns (uint256) {
    uint256 temp_unstake = _unstakeCFXs;
    _unstakeCFXs = 0;
    emit HandleUnstake(msg.sender, temp_unstake);
    return temp_unstake;
  }

  function setxCFXValue(uint256 xcfxvalue) public onlyBridge returns (uint256){
    _exchangeSummary.xcfxvalues = xcfxvalue;
    emit SetxCFXValue(msg.sender, _exchangeSummary.xcfxvalues);
    return  _exchangeSummary.xcfxvalues;
  }

  function setlockedvotes(uint256 lockedvotes) public onlyBridge returns (uint256){
    _exchangeSummary.alloflockedvotes = lockedvotes;
    emit Setlockedvotes(msg.sender, _exchangeSummary.alloflockedvotes);
    return  _exchangeSummary.alloflockedvotes;
  }

  function espacebalanceof(address _addr) public view returns(uint256) {
    return _addr.balance;
  }

  address storageBridge;
  // ======================== contract base methods =====================
  fallback() external payable {}
  receive() external payable {}

}