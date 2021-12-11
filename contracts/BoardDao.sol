// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Ownable.sol";
import "./Token.sol";

contract BoardDao is Ownable, ERC20Burnable {
  address creator;
  address creator;
  address invesDao;

  Token companyBank;

  uint constant votingPeriod = 2 weeks;
  uint constant disputablePeriod = 1 weeks;
  uint constant disputeCollateral = ;
  uint constant quorumSuccessPeriod;
  uint256 constant initialSupply = 100;

  struct Proposal {
    uint64 amountToBeDebited;
    string purpose;
    address creator;
    address payable recipient;
  }

  Proposal[] public proposals;

  constructor(
    string memory name,
    string memory symbol,
    address owner
  ) ERC20(name, symbol) {
      dao_admin = owner;
      _mint(dao_admin, initialSupply);
  }

}