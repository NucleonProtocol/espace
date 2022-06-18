
/*
Copyright (c) [2022] [2022 Artii. All rights reserved.]
[Mixed Multipool] is licensed under the Artii BSL v1.0
You can use this software according to the terms and conditions of the Artii BSL v1.0
You may obtain a copy of Artii BSL v1.0 at:
    http://
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
PURPOSE.
See the Artii BSL v1.0 for more details.
*/


pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
//import "@openzeppelin/contracts/utils/Address.sol";
import "./seed_verif.sol";
// interface seed_verification{
//     function init_verify(uint256 seed1,uint256 seed2,uint256 seed3,bytes32 key_of_seed) external view returns (bool, uint256);
//     function second_verify(uint256 verify_num) external view returns (bool, uint256);
// }

contract XE_space_dice is IERC777Recipient, Ownable, Initializable{
    using SafeMath for uint256;
    address verifyaddress;
    address this_addr;
    address ERC20_addr;
    uint256 unlocked;
    bool owner_locking;

    modifier lock() {
        require(unlocked == 1, 'LOCKED, wait');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    modifier lockinglocking() {
        require(owner_locking == false, 'LOCKED by Emergency');
        _;
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    // keccak256("ERC777TokensRecipient")
    IERC1820Registry private _erc1820 = IERC1820Registry(0x88887eD889e776bCBe2f0f9932EcFaBcDfCd1820);
    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;
    // constructor() ERC777("Artii Swap core", "ASWAP", new address[](0)){
    //     _erc1820.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    //     this_addr = address(this);
    // }

    function initialize() public initializer {
        _erc1820 = IERC1820Registry(0x88887eD889e776bCBe2f0f9932EcFaBcDfCd1820);
        _erc1820.setInterfaceImplementer(address(this), 
                                     0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b, 
                                     address(this));
        this_addr = address(this);

    }
 
    function Locking_by_Owner(bool _state) public onlyOwner{
        owner_locking = _state;
    }
    
    function Start( uint256 _amount_in,
                    uint256 _user_num,
                    uint256 seed1,
                    uint256 seed2,
                    uint256 seed3,
                    bytes32 key_of_seed) public payable lockinglocking lock returns(uint256){
        require(isContract(msg.sender)==false,'Cant be a Contract');
        //uint256 amount_out;
        uint256 verify_account;
        uint256 random_num;
        uint256 choised_num;
        uint256 id_num;
        bool true_false;

        (true_false,choised_num)=seed_veri(verifyaddress).init_verify( seed1,  seed2, seed3, key_of_seed);
        if(true_false){
            verify_account+=1;
        }
        else{
            ERC20(ERC20_addr).transferFrom(msg.sender,this_addr,_amount_in);
            return 0;
        }
        (true_false,id_num)=seed_veri(verifyaddress).second_verify(seed1+seed2+seed3);
        if(true_false){
            verify_account+=1;
        }
        else{
            ERC20(ERC20_addr).transferFrom(msg.sender,this_addr,_amount_in);
            return 0;
        }
        if(choised_num==0){
            random_num=uint256(keccak256(abi.encodePacked(seed1+119)));
        }
        else if(choised_num==1){
            random_num=uint256(keccak256(abi.encodePacked(seed2+234)));
        }
        else if(choised_num==2){
            random_num=uint256(keccak256(abi.encodePacked(seed3+312)));
        }
        else{
            return 0;
        }
        if(verify_account==2){
            if(random_num==_user_num){
                ERC20(ERC20_addr).transfer(msg.sender,_amount_in);
            }
            else{
                ERC20(ERC20_addr).transferFrom(msg.sender,this_addr,_amount_in);
            }
        }
        return _amount_in;
    }

    // ERC 777 ADD
    function tokensReceived(
      address operator,
      address from,
      address to,
      uint amount,
      bytes calldata userData,
      bytes calldata operatorData
    ) external override{
    
    }

}
