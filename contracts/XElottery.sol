
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
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./seed_verif.sol";

contract lottery {
    address this_addr;
    address owner_addr;
    address admin_addr;
    uint256 time_last;
    uint256 Lottery_interval;
    bool opened;
    uint256 issues;
    address verifyaddress;
    uint256 user_amount;
    address ERC20_addr;

    struct UserStorage {
    uint256 num_A;  
    uint256 num_B; 
    uint256 num_C;
    uint256 num_D;
    uint256 num_E;
    uint256 num_F;
    uint256 num_X;
    uint256 amount;
    }

    struct issuesstorage{
    uint256 num_A;  
    uint256 num_B; 
    uint256 num_C;
    uint256 num_D;
    uint256 num_E;
    uint256 num_F;
    uint256 num_X;
    }
    mapping(uint256 => bytes32) id_key;
    mapping(address => mapping(uint256 => UserStorage)) user_lottery;
    mapping(uint256 => address ) all_user_addr;
    mapping(address => uint256 ) user_id;
    mapping(address => uint256 ) user_id_opened;
    mapping(uint256 => issuesstorage ) issue_opened;

    mapping(address => mapping(uint256 => uint256) ) usermax;//addr->issue->max
    mapping(address => mapping(uint256 => uint256) ) userearned;//addr->issue->earned
    mapping(uint256 => uint256 ) poolmax; //issue->poolmax
    mapping(uint256 => uint256 ) pooldistribute;  //issue->pooldistribute
    mapping(uint256 => address[]) max_issue_user;

    modifier only_owner() {
        require(msg.sender == owner_addr, 'Must owner');
        _;
    }
    modifier only_admin() {
        require(msg.sender == admin_addr, 'Must admin');
        _;
    }
    modifier only_opened() {
        require(opened, 'not opened');
        _;
    }

    constructor() {
        owner_addr = msg.sender;
        this_addr = address(this);
        Lottery_interval=2 days;
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function user_draw(uint256 _num_A, 
                  uint256 _num_B, 
                  uint256 _num_C, 
                  uint256 _num_D, 
                  uint256 _num_E, 
                  uint256 _num_F, 
                  uint256 _num_X, 
                  uint256 _amount) external {//if input is 10, means all num have drawed;
        require(block.timestamp>=time_last+3600, 'Time is not start');
        if(user_id[msg.sender]==0){
            all_user_addr[user_amount]=msg.sender;
            user_amount++;
        }
        ERC20(ERC20_addr).transferFrom(msg.sender,this_addr,_amount);
        user_lottery[msg.sender][user_id[msg.sender]].num_A=_num_A;
        user_lottery[msg.sender][user_id[msg.sender]].num_B=_num_B;
        user_lottery[msg.sender][user_id[msg.sender]].num_C=_num_C;
        user_lottery[msg.sender][user_id[msg.sender]].num_D=_num_D;
        user_lottery[msg.sender][user_id[msg.sender]].num_E=_num_E;
        user_lottery[msg.sender][user_id[msg.sender]].num_F=_num_F;
        user_lottery[msg.sender][user_id[msg.sender]].num_X=_num_X;
        user_lottery[msg.sender][user_id[msg.sender]].amount=_amount;
        user_id[msg.sender]+=1;
    }


    function set_admin(address _admin_addr) external only_owner {
        admin_addr=_admin_addr;
    }

    function  admin_drawing(uint256 _issue,
                      uint256 seed1,
                      uint256 seed2,
                      uint256 seed3,
                      bytes32 key_of_seed) internal only_admin returns (bool){
        require(block.timestamp>=time_last+Lottery_interval, 'Time is not over');
        require(issues==_issue, 'issue is not right');
        require(isContract(msg.sender)==false,'Cant be a Contract');
        //uint256 amount_out;
        uint256 verify_account;
        uint256 choised_num;
        uint256 id_num;
        bool true_false;

        (true_false,choised_num)=seed_veri(verifyaddress).init_verify( seed1,  seed2, seed3, key_of_seed);
        if(true_false){
            verify_account+=1;
        }
        else{
            return false;
        }
        (true_false,id_num)=seed_veri(verifyaddress).second_verify(seed1+seed2+seed3);
        if(true_false){
            verify_account+=1;
        }
        else{
            return false;
        }
        if(choised_num==0){
            issue_opened[issues].num_A=uint256(keccak256(abi.encodePacked(seed1+119)))%10;
            issue_opened[issues].num_B=uint256(keccak256(abi.encodePacked(seed2+235)))%10;
            issue_opened[issues].num_C=uint256(keccak256(abi.encodePacked(seed3+378)))%10;
            issue_opened[issues].num_D=uint256(keccak256(abi.encodePacked(seed1+seed3%seed2)))%10;
            issue_opened[issues].num_E=uint256(keccak256(abi.encodePacked(seed2+seed3%seed1)))%10;
            issue_opened[issues].num_F=uint256(keccak256(abi.encodePacked(seed3+seed2%seed1)))%10;
            issue_opened[issues].num_X=uint256(keccak256(abi.encodePacked(seed3%seed1+seed2+seed3)))%10;
        }
        else if(choised_num==1){
            issue_opened[issues].num_A=uint256(keccak256(abi.encodePacked(seed2+335)))%10;
            issue_opened[issues].num_B=uint256(keccak256(abi.encodePacked(seed3+112)))%10;
            issue_opened[issues].num_C=uint256(keccak256(abi.encodePacked(seed1+109)))%10;
            issue_opened[issues].num_D=uint256(keccak256(abi.encodePacked(seed1+seed3%seed2)))%10;
            issue_opened[issues].num_E=uint256(keccak256(abi.encodePacked(seed2+seed3%seed1)))%10;
            issue_opened[issues].num_F=uint256(keccak256(abi.encodePacked(seed3+seed2%seed1)))%10;
            issue_opened[issues].num_X=uint256(keccak256(abi.encodePacked(seed3%seed1+seed2+seed3)))%10;
        }
        else if(choised_num==2){
            issue_opened[issues].num_A=uint256(keccak256(abi.encodePacked(seed3+458)))%10;
            issue_opened[issues].num_B=uint256(keccak256(abi.encodePacked(seed1+213)))%10;
            issue_opened[issues].num_C=uint256(keccak256(abi.encodePacked(seed2+567)))%10;
            issue_opened[issues].num_D=uint256(keccak256(abi.encodePacked(seed1+seed3%seed2)))%10;
            issue_opened[issues].num_E=uint256(keccak256(abi.encodePacked(seed2+seed3%seed1)))%10;
            issue_opened[issues].num_F=uint256(keccak256(abi.encodePacked(seed3+seed2%seed1)))%10;
            issue_opened[issues].num_X=uint256(keccak256(abi.encodePacked(seed3%seed1+seed2+seed3)))%10;
        }
        else{
            return false;
        }
        issues++;
        time_last+=Lottery_interval;
        opened==true;
        return true;
    }

    function reward_distribute() internal only_admin only_opened returns (bool){
        // this function culculate the rewards to the user
        // pooldistribute \ userearned  :: all of the getted
        // poolmax \ usermax  :: get first prize
        //
        uint256 samenum;
        uint256 samex;
        uint256 buy_amount;
        for(uint i=0;i<user_amount;i++){
            if(user_id[all_user_addr[i]]>user_id_opened[all_user_addr[i]]){
                for(uint j=user_id_opened[all_user_addr[i]];j<user_id[all_user_addr[i]];j++){
                    samenum=0;
                    samex=0;
                    buy_amount=user_lottery[all_user_addr[i]][j].amount;
                    if(user_lottery[all_user_addr[i]][j].num_A==issue_opened[issues-1].num_A||(user_lottery[all_user_addr[i]][j].num_A==10)){samenum+=1;}
                    if(user_lottery[all_user_addr[i]][j].num_B==issue_opened[issues-1].num_B||(user_lottery[all_user_addr[i]][j].num_B==10)){samenum+=1;}
                    if(user_lottery[all_user_addr[i]][j].num_C==issue_opened[issues-1].num_C||(user_lottery[all_user_addr[i]][j].num_C==10)){samenum+=1;}
                    if(user_lottery[all_user_addr[i]][j].num_D==issue_opened[issues-1].num_D||(user_lottery[all_user_addr[i]][j].num_D==10)){samenum+=1;}
                    if(user_lottery[all_user_addr[i]][j].num_E==issue_opened[issues-1].num_E||(user_lottery[all_user_addr[i]][j].num_E==10)){samenum+=1;}
                    if(user_lottery[all_user_addr[i]][j].num_F==issue_opened[issues-1].num_F||(user_lottery[all_user_addr[i]][j].num_F==10)){samenum+=1;}
                    if(user_lottery[all_user_addr[i]][j].num_X==issue_opened[issues-1].num_X){samex=1;   }
                    if(samenum==6){
                        poolmax[issues-1]+=buy_amount;
                        usermax[all_user_addr[i]][issues-1]+=buy_amount;
                        if(samex==1){
                            poolmax[issues-1]+=1;
                            usermax[all_user_addr[i]][issues-1]+=buy_amount;
                        }
                    }
                    else if(samenum==5){
                        userearned[all_user_addr[i]][issues-1]+=100*buy_amount;
                        if(samex==1){userearned[all_user_addr[i]][issues-1]+=100*buy_amount;}
                    }
                    else if(samenum==4){
                        userearned[all_user_addr[i]][issues-1]+=10*buy_amount;
                        if(samex==1){userearned[all_user_addr[i]][issues-1]+=10*buy_amount; }
                    }
                    else if(samenum==3){
                        userearned[all_user_addr[i]][issues-1]+=2*buy_amount;
                        if(samex==1){userearned[all_user_addr[i]][issues-1]+=2*buy_amount;  }
                    }
                    else if(samenum<3){
                        if(samex==1){userearned[all_user_addr[i]][issues-1]+=2*buy_amount;  }
                    }
                }
                pooldistribute[issues-1]+=userearned[all_user_addr[i]][issues-1];
            }
        }
        return(true);
    }

    function distributing() internal only_admin only_opened returns (bool){
        //uint all_user_num=alluser_storage.length;
        uint256 balanceERC20=ERC20(ERC20_addr).balanceOf(this_addr);
        uint256 oneMaX=balanceERC20*3/(10*poolmax[issues-1]);

        for(uint i=0;i<user_amount;i++){
            if(userearned[all_user_addr[i]][issues-1]>0){
                ERC20(ERC20_addr).transfer(all_user_addr[i],userearned[all_user_addr[i]][issues-1]);
            }
            if(usermax[all_user_addr[i]][issues-1]>0){
                ERC20(ERC20_addr).transfer(all_user_addr[i],oneMaX*usermax[all_user_addr[i]][issues-1]);
            }
        }
        opened==false;
        return(true);
    }

    function lottery_open(uint256 _issue,
                      uint256 seed1,
                      uint256 seed2,
                      uint256 seed3,
                      bytes32 key_of_seed) internal only_admin {
                           require(admin_drawing(_issue,seed1,seed2,seed3,key_of_seed),'drawing err');
                           require(reward_distribute(),'reward err');
                           require(distributing(),'distributing err');
                      }
}
