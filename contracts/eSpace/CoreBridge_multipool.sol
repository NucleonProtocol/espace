//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../ICrossSpaceCall.sol";
import "../IPoSPool.sol";

contract CoreBridge_multipool is Ownable {
  using SafeMath for uint256;
  CrossSpaceCall internal crossSpaceCall;

  address[] public poolAddress;
  address public eSpacePoolAddress;

  constructor () {
    initialize();
  }

  function initialize() public {
    crossSpaceCall = CrossSpaceCall(0x0888000000000000000000000000000000000006);
  }

  function addPoolAddress(address _poolAddress) public onlyOwner {
    poolAddress.push(_poolAddress);
  }

  function changePoolAddress(address _oldpoolAddress,address _newpoolAddress) public onlyOwner {
    uint256 pool_sum = poolAddress.length;
    for(uint256 i=0;i<pool_sum;i++)
    {
        if(poolAddress[i]==_oldpoolAddress)
        {
            poolAddress[i]=_newpoolAddress;
        }
    }
  }
  function delePoolAddress(address _oldpoolAddress) public onlyOwner {
    uint256 pool_sum = poolAddress.length;
    for(uint256 i=0;i<pool_sum;i++)
    {
        if(poolAddress[i]==_oldpoolAddress)
        {
            poolAddress[i]= poolAddress[pool_sum-1];
            poolAddress.pop();
        }
    }
  }

  function getPoolAddress() public returns (address[] memory ) {
    return poolAddress;
  }

  function setESpacePoolAddress(address _eSpacePoolAddress) public onlyOwner {
    eSpacePoolAddress = _eSpacePoolAddress;
  }

  function ePoolAddrB20() public view returns (bytes20) {
    return bytes20(eSpacePoolAddress);
  }

  function queryCrossingVotes() public returns (uint256) {
    bytes memory rawCrossingVotes = crossSpaceCall.callEVM(ePoolAddrB20(), abi.encodeWithSignature("crossingVotes()"));
    return abi.decode(rawCrossingVotes, (uint256));
  }

  function queryUnstakeLen() public returns (uint256) {
    bytes memory rawUnstakeLen = crossSpaceCall.callEVM(ePoolAddrB20(), abi.encodeWithSignature("unstakeLen()"));
    return abi.decode(rawUnstakeLen, (uint256));
  }

  function queryInterest(uint256 _num) public view returns (uint256) {
    IPoSPool posPool = IPoSPool(poolAddress[_num]);
    uint256 interest = posPool.userInterest(address(this));
    return interest;
  }

  function queryUserSummary(uint256 _num) public view returns (IPoSPool.UserSummary memory) {
    IPoSPool posPool = IPoSPool(poolAddress[_num]);
    IPoSPool.UserSummary memory userSummary = posPool.userSummary(address(this));
    return userSummary;
  }

  function syncAPYandClaimInterest() public onlyOwner {
    syncAPY();
    claimInterest();
  }

  function syncAPY() public {
    uint256 pool_sum = poolAddress.length;
    //IPoSPool.poolSummary memory poolSummary;
    uint256 APYi;
    uint256 SUMi;
    for(uint256 i=0;i<pool_sum;i++)
    {
        SUMi = SUMi +  IPoSPool(poolAddress[i]).poolSummary().available;
        APYi = APYi + IPoSPool(poolAddress[i]).poolSummary().available*IPoSPool(poolAddress[i]).poolAPY();
    }
    //IPoSPool posPool = IPoSPool(poolAddress);
    uint256 apy = APYi.div(SUMi);
    crossSpaceCall.callEVM(ePoolAddrB20(), abi.encodeWithSignature("setPoolAPY(uint256)", apy));
  }

  function crossStake(uint256 _num) public onlyOwner {
    uint256 crossingVotes = queryCrossingVotes();
    uint256 mappedBalance = crossSpaceCall.mappedBalance(address(this));
    uint256 amount = crossingVotes * 1000 ether;
    if (crossingVotes > 0 && mappedBalance >= amount) {
      crossSpaceCall.withdrawFromMapped(amount);
      crossSpaceCall.callEVM(ePoolAddrB20(), abi.encodeWithSignature("handleCrossingVotes(uint256)", crossingVotes));
      IPoSPool posPool = IPoSPool(poolAddress[_num]);
      posPool.increaseStake{value: amount}(uint64(crossingVotes));
    }
  }

  function claimInterest() public onlyOwner {
    uint256 pool_sum = poolAddress.length;
    IPoSPool posPool;
    uint256 interest;
    for(uint256 i=0;i<pool_sum;i++)
    {
      posPool = IPoSPool(poolAddress[i]);
      interest = posPool.userInterest(address(this));
      if (interest > 0) {
        posPool.claimInterest(interest);
        crossSpaceCall.transferEVM{value: interest}(ePoolAddrB20());
      }
    }
  }

  function claimAndCrossInterest() public onlyOwner {
    uint256 pool_sum = poolAddress.length;
    IPoSPool posPool;
    uint256 interest;
    for(uint256 i=0;i<pool_sum;i++)
    {
      posPool = IPoSPool(poolAddress[i]);
      interest = posPool.userInterest(address(this));
      if (interest > 0) {
        posPool.claimInterest(interest);
        crossSpaceCall.callEVM{value: interest}(ePoolAddrB20(), abi.encodeWithSignature("receiveInterest()"));
      }
    }
  }

  function handleUnstake(uint256 _num) public onlyOwner {
    uint256 unstakeLen = queryUnstakeLen();
    if (unstakeLen == 0) return;
    if (unstakeLen > 50) unstakeLen = 50; // max 50 unstakes per call
    IPoSPool posPool = IPoSPool(poolAddress[_num]);
    IPoSPool.UserSummary memory userSummary = posPool.userSummary(address(this));
    uint256 available = userSummary.locked;
    bytes memory rawFirstUnstakeVotes ;
    uint256 firstUnstakeVotes;
    if (available == 0) return;
    for(uint256 i = 0; i < unstakeLen; i++) {
      rawFirstUnstakeVotes = crossSpaceCall.callEVM(ePoolAddrB20(), abi.encodeWithSignature("firstUnstakeVotes()"));
      firstUnstakeVotes = abi.decode(rawFirstUnstakeVotes, (uint256));
      if (firstUnstakeVotes == 0) break;
      if (firstUnstakeVotes > available) break;
      posPool.decreaseStake(uint64(firstUnstakeVotes));
      crossSpaceCall.callEVM(ePoolAddrB20(), abi.encodeWithSignature("handleUnstakeTask()"));
      available -= firstUnstakeVotes;
    }
  }

  function withdrawVotes() public onlyOwner {
    uint256 pool_sum = poolAddress.length;
    IPoSPool posPool;
    uint256 interest;
    uint256 transferValue;
    for(uint256 i=0;i<pool_sum;i++)
    {
      posPool = IPoSPool(poolAddress[i]);
      IPoSPool.UserSummary memory userSummary = posPool.userSummary(address(this));
      if (userSummary.unlocked > 0) 
      {
        posPool.withdrawStake(userSummary.unlocked);
        // transfer to eSpacePool and call method
        transferValue = userSummary.unlocked * 1000 ether;
        crossSpaceCall.callEVM{value: transferValue}(ePoolAddrB20(), abi.encodeWithSignature("handleUnlockedIncrease(uint256)", userSummary.unlocked));
      }
    }
  }

  function callEVM(address addr, bytes calldata data) public onlyOwner {
    crossSpaceCall.callEVM(bytes20(addr), data);
  }

  fallback() external payable {}
  receive() external payable {}
}