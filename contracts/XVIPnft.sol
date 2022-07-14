// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
//import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XVIP is ERC721URIStorage, Ownable, Initializable {
    using SafeMath for uint256;
    event MintXVip(address _onwer, uint256 _tokenId, string metedate);
    event BurnXVip(address _onwer, uint256 _tokenId);
    //using Counters for Counters.Counter;
    uint256 private _tokenIds1;
    uint256 private _tokenIds2;
    uint256 private _tokenIds3;
    uint256 private started;
    string base_URI;
    address XET_address;
    mapping(uint256 => uint256) private userVIPlevel_count; //------------------
    mapping(address => uint256) private Max_vip_level;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    mapping(uint256 => address[]) public ownerOfAddress;

    constructor() ERC721("X-E Space VIP Card", "XVIP") {
        _tokenIds1 = 0;
        _tokenIds2 = 1000;
        _tokenIds3 = 10000;
    }

    function initialize() public initializer {
        //transferOwnership(owner());
        //ERC721("X-E space VIP Card", "XVIP");
    }

    modifier onlystarted1() {
        require(started == 1, " Not start 1");
        _;
    }
    modifier onlystarted2() {
        require(started == 2, " Not start 2");
        _;
    }
    modifier onlystarted3() {
        require(started == 3, " Not start 3");
        _;
    }

    function set_start(uint256 _num) external onlyOwner {
        started = _num;
    }
    function set_XETaddr(address _addr) external onlyOwner {
        XET_address = _addr;
    }
    function get_setting() external view returns(address _addr, uint256 _num) {
        return (XET_address, started);
    }
    function get_current_ids(uint256 _num) external view returns(uint256) {
        if(_num==1){return _tokenIds1;}
        if(_num==2){return _tokenIds2;}
        if(_num==3){return _tokenIds3;}
        return 0;
    }

    function mint_xvip(string memory tokenURI, uint256 _id, uint256 _id_type)
        public
        onlystarted1
        returns (uint256)
    {
        uint256 newItemId;
        if(_id_type == 1) {
            require(_tokenIds1 < 100, "exseed the mint amount!");
            _tokenIds1 += 1;
            require(_tokenIds1 == _id, " ID wrong!");
            newItemId = _tokenIds1;
            IERC20(XET_address).transferFrom(msg.sender, address(this), 200 ether);
        }
        else if(_id_type == 2) {
            require(_tokenIds2 < 2000, "exceed the mint amount!");
            _tokenIds2 += 1;
            require(_tokenIds2 == _id, " ID wrong!");
            newItemId = _tokenIds2;
            IERC20(XET_address).transferFrom(msg.sender, address(this), 20 ether);
        }
        else if(_id_type == 3) {
            require(_tokenIds3 < 100000, "exceed the mint amount!");
            _tokenIds3 += 1;
            require(_tokenIds3 == _id, " ID wrong!");
            newItemId = _tokenIds3;
            IERC20(XET_address).transferFrom(msg.sender, address(this), 2 ether);
        }

        _addTokenToAllTokensEnumeration(newItemId);
        _addTokenToOwnerEnumeration(msg.sender, newItemId);

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        if (Max_vip_level[msg.sender] < 1 || Max_vip_level[msg.sender] > _id_type) {
            Max_vip_level[msg.sender] = 1;
        }
        emit MintXVip(msg.sender, newItemId, tokenURI);
        return newItemId;
    }

    // function mint_xvip_1(string memory tokenURI, uint256 _id)
    //     public
    //     onlystarted1
    //     returns (uint256)
    // {
    //     require(_tokenIds1 < 100, "exseed the mint amount!");
    //     _tokenIds1 += 1;
    //     require(_tokenIds1 == _id, " ID wrong!");
    //     IERC20(XET_address).transferFrom(msg.sender, address(this), 200 ether);
    //     uint256 newItemId = _tokenIds1;
    //     _addTokenToAllTokensEnumeration(newItemId);
    //     _addTokenToOwnerEnumeration(msg.sender, newItemId);

    //     _mint(msg.sender, newItemId);
    //     _setTokenURI(newItemId, tokenURI);
    //     if (Max_vip_level[msg.sender] < 1 || Max_vip_level[msg.sender] > 1) {
    //         Max_vip_level[msg.sender] = 1;
    //     }
    //     emit MintXVip(msg.sender, newItemId, tokenURI);
    //     return newItemId;
    // }

    // function mint_xvip_2(string memory tokenURI, uint256 _id)
    //     public
    //     onlystarted2
    //     returns (uint256)
    // {
    //     require(_tokenIds2 < 2000, "exceed the mint amount!");
    //     _tokenIds2 += 1;
    //     require(_tokenIds2 == _id, " ID wrong!");
        
    //     IERC20(XET_address).transferFrom(msg.sender, address(this), 20 ether);
    //     uint256 newItemId = _tokenIds2;
    //     _addTokenToAllTokensEnumeration(newItemId);
    //     _addTokenToOwnerEnumeration(msg.sender, newItemId);

    //     _mint(msg.sender, newItemId);
    //     _setTokenURI(newItemId, tokenURI);
    //     if (Max_vip_level[msg.sender] < 1 || Max_vip_level[msg.sender] > 2) {
    //         Max_vip_level[msg.sender] = 2;
    //     }
    //     emit MintXVip(msg.sender, newItemId, tokenURI);
    //     return newItemId;
    // }

    // function mint_xvip_3(string memory tokenURI, uint256 _id)
    //     public
    //     onlystarted3
    //     returns (uint256)
    // {
    //     require(_tokenIds3 < 100000, "exceed the mint amount!");
    //     _tokenIds3 += 1;
    //     require(_tokenIds3 == _id, " ID wrong!");

    //     IERC20(XET_address).transferFrom(msg.sender, address(this), 2 ether);
    //     uint256 newItemId = _tokenIds3;
    //     _addTokenToAllTokensEnumeration(newItemId);
    //     _addTokenToOwnerEnumeration(msg.sender, newItemId);
        
    //     _mint(msg.sender, newItemId);
    //     _setTokenURI(newItemId, tokenURI);
    //     if (Max_vip_level[msg.sender] < 1 || Max_vip_level[msg.sender] > 3) {
    //         Max_vip_level[msg.sender] = 3;
    //     }
    //     emit MintXVip(msg.sender, newItemId, tokenURI);
    //     return newItemId;
    // }

    function level_up_mint(uint256[] memory _ids, string memory tokenURI, uint256 _id)
        public
        onlystarted3
        returns (uint256)
    {
        require(_ids.length == 12, "err amount");
        uint256 newItemId;
        if (_ids[0] > 1000 && _ids[0] < 10000) {
            _tokenIds1 += 1;
            require(_tokenIds1 == _id, " ID wrong!");
            require(_tokenIds1 < 999, "exceed the upgrade amount!");
            for (uint256 i = 1; i < 12; i++) {
                require(_ids[i] > 1000 && _ids[i] < 10000, "need same rank");
            }
            for (uint256 i = 0; i < 12; i++) {
                _removeTokenFromOwnerEnumeration(msg.sender, _ids[i]);
                _removeTokenFromAllTokensEnumeration(_ids[i]);
                _burn(_ids[i]);
            }
            newItemId = _tokenIds1;
            _mint(msg.sender, newItemId);
            if (Max_vip_level[msg.sender] < 1 || Max_vip_level[msg.sender] > 1) {
                Max_vip_level[msg.sender] = 1;
            }
        } else if (_ids[0] > 10000) {
            _tokenIds2 += 1;
            require(_tokenIds2 == _id, " ID wrong!");
            require(_tokenIds2 < 9999, "exceed the upgrade amount!");
            for (uint256 i = 1; i < 12; i++) {
                require(_ids[i] > 10000, "need same rank");
            }
            for (uint256 i = 0; i < 12; i++) {
                _removeTokenFromOwnerEnumeration(msg.sender, _ids[i]);
                _removeTokenFromAllTokensEnumeration(_ids[i]);
                _burn(_ids[i]);
            }
            newItemId = _tokenIds2;
            _mint(msg.sender, newItemId);
            if (Max_vip_level[msg.sender] < 1 || Max_vip_level[msg.sender] > 2) {
                Max_vip_level[msg.sender] = 2;
            }
        }
        _addTokenToAllTokensEnumeration(newItemId);
        _addTokenToOwnerEnumeration(msg.sender, newItemId);
        emit MintXVip(msg.sender, newItemId, tokenURI);
        return (newItemId);
    }

    function tokenOf(address owner) public view returns (uint256[] memory) {
        //require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner];
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return base_URI;
    }

    function set_baseURI(string memory _uri) public  onlyOwner {
        base_URI = _uri;
    }

    // function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    //       require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    //       string memory baseURI = _baseURI();
    //       return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    // }
    function Maxlevelof(address _owner) public view returns (uint256) {
        return Max_vip_level[_owner];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
        address[] storage addr = ownerOfAddress[tokenId];
        if (addr.length > 0) {
            addr.pop();
        }
        addr.push(to);
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].pop();

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
        // delete _ownedTokensIndex[tokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.pop();
        _allTokensIndex[tokenId] = 0;
    }
}
