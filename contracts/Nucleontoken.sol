// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract nucleon_token is ERC20 {
  // ======================== configs =========================
    ERC20 token;
    string  _name;
    string  _symbol;

  constructor(uint256 initialSupply) ERC20("Nucleon Governance token", "NUN") {
    owner = msg.sender;
    _mint(msg.sender, initialSupply);
  }
  function initialize(ERC20 _token) public initializer {
        token = _token;
        owner = msg.sender;
        unlocked = 1;
        _name = "X nucleon CFX";
        _symbol = "xCFX";
  }
  /**
     * @dev Returns the name of the token.
     */
  function name() public view virtual override returns (string memory) {
    return _name;
  }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
  function symbol() public view virtual override returns (string memory) {
      return _symbol;
  }
}
