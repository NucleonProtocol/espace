
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

contract seed_veri {

    
    address owner_addr;
    address admin_addr;
    uint256 id;
    mapping(uint256 => bytes32) id_key;

    modifier only_owner() {
        require(msg.sender == owner_addr, 'Must owner');
        _;
    }
    modifier only_admin() {
        require(msg.sender == admin_addr, 'Must admin');
        _;
    }

    constructor() {
        owner_addr = msg.sender;
    }
    function storage_key(bytes32 _sum_hash,uint256 _id) external only_admin {
        require(_id==id,'ID is not right');
        id_key[id]=_sum_hash;
        id++;
    }
    function set_admin(address _admin_addr) external only_owner {
        admin_addr=_admin_addr;
    }
    function id_looking() external view only_owner returns(uint256){
        return (id);
    }
   
    function init_verify(uint256 _seed1,uint256 _seed2,uint256 _seed3,bytes32 _key_of_seed) external pure returns (bool, uint256){
        uint256 seed=(_seed1+_seed2+_seed3)%3;
        bytes32 key;
        if(seed==0){
            key=sha256(abi.encodePacked(_seed2+_seed3));
        }
        else if(seed==1){
            key=sha256(abi.encodePacked(_seed1+_seed3));
        }
        else if(seed==2){
            key=sha256(abi.encodePacked(_seed1+_seed3));
        }
        //require(key!=0,"wrong key 1");
        if(key==_key_of_seed){
            return (true,seed);
            }
        else{
            return (false,10);
            }
    }

    function second_verify(uint256 _verify_num) external view returns (bool, uint256){
        bytes32 veri_num=sha256(abi.encodePacked(_verify_num+id));
        if(veri_num==id_key[id]){
            return (true,id);
            }
        else{
            return (false,0);
            }
    }

}
