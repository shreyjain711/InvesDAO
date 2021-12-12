// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Token.sol";
import "./RaiseDao.sol";

contract InvesDao {
  uint constant maxSupply = 10 ** 10;
  Token iDAO = new Token("InvesDao", "iDAO", maxSupply);
  
}
