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
    string title
    string idea;
    string ipfs;
    string socialThread;
    address creator;
  }

  Proposal[] public proposals;

  mapping (address => uint) voteBank;
  mapping (uint => uint) proposalVotes;

  event proposalCreated(address _from, uint _proposalId);
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

  modifier isMember () {
    require(companyToken.balanceOf(msg.sender) > 0);
    _;
  }

  function applyForMembership() payable public membershipAvailable {
    require(msg.value <= yetToBeRaised, "Not enough membership tokens available");
    yetToBeRaised -= msg.value;
    companyToken.transfer(msg.sender, msg.value);
    emit TransferReceived(msg.sender, msg.value);
  }

  function createProposal(string _title, string _idea, string _ipfs, string _socialThread) public returns (Proposal) {
    Proposal memory newProp = new Proposal(_title, _idea, _ipfs, _socialThread, msg.sender));
    proposals.push(newProp);
    return newProp;
  }

  function getAllProposals() public view returns (Proposal[]) {
    return proposals;
  }

  function getAllProposals() public view returns (uint) {
    return proposals.length;
  }

  function voteForProposal(uint _proposalId, uint _lockedTokens) public payable returns (bool) {
    
  }

  function disputeProposal(uint _proposalId, uint_collateral) public payable returns (bool) {

  }

}
