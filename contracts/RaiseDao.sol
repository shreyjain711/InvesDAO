// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Token.sol";

contract RaiseDao {
  address invesDao;

  Token companyToken;

  uint raiseGoal;
  uint yetToBeRaised;
  uint constant votingPeriod = 2 weeks;
  uint constant disputablePeriod = 1 weeks;
  uint constant disputeCollateral = 100 ether;
  

  struct Proposal {
    uint64 amountToBeDebited;
    string idea;
    address creator;
  }

  Proposal[] public proposals;

  event TransferReceived(address _from, uint _amount);

  constructor(
    string memory _daoTokenName,
    string memory _daoTokenSymbol,
    uint _raiseGoal
  )  {
    invesDao = msg.sender;
    companyToken = new Token(_daoTokenName, _daoTokenSymbol, _raiseGoal);
    raiseGoal = _raiseGoal;
    yetToBeRaised = _raiseGoal;
  }

  modifier membershipAvailable() {
    require(yetToBeRaised > 0);
    _;
  }

  function applyForMembership() payable public membershipAvailable {
    require(msg.value <= yetToBeRaised, "Not enough membership tokens available");
    yetToBeRaised -= msg.value;
    companyToken.transfer(msg.sender, msg.value);
    emit TransferReceived(msg.sender, msg.value);
  }
}
