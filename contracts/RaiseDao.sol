// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Token.sol";
import "./Ownable.sol";

contract RaiseDao is Ownable {
  address invesDao;
  Token companyToken;

  uint raiseGoal;
  uint yetToBeRaised;
  DAOStatus stageOfDAO;
  uint constant votingPeriod = 2 weeks;
  uint constant disputablePeriod = 1 weeks;
  uint constant minDisputeCollateral = 100 ether;

  mapping (address => uint) depositorBank;
  address[] depositors;
  
  enum DAOStatus {VOTING, EXECUTING}
  enum proposalStatus {ACTIVE, DISPUTED, ACCEPTED}

  struct Proposal {
    string title;
    string idea;
    string ipfs;
    string socialThread;
    address creator;
    proposalStatus status;
    address disputor;
  }

  Proposal[] public proposals;

  mapping (address => uint) voteBank;
  address[] voters;
  uint totalVoteTokens;

  mapping (int => uint) proposalVotes;

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
    stageOfDAO = DAOStatus.VOTING;
  }

  modifier membershipAvailable() {
    require(yetToBeRaised > 0);
    _;
  }

  modifier isMember () {
    require(companyToken.balanceOf(msg.sender) > 0);
    _;
  }

  modifier currentlyRaising() {
    require(stageOfDAO == DAOStatus.VOTING);
    _;
  }

  modifier currentlyExecutiveBoard() {
    require(stageOfDAO == DAOStatus.EXECUTING);
    _;
  }

  function applyForMembership() payable public membershipAvailable currentlyRaising {
    require(msg.value <= yetToBeRaised, "Not enough membership tokens available");
    yetToBeRaised -= msg.value;
    depositorBank[msg.sender] = msg.value;
    depositors.push(msg.sender);
    companyToken.transfer(msg.sender, msg.value); 
    emit TransferReceived(msg.sender, msg.value);
  }

  function createProposal(string memory _title, string memory _idea, string memory _ipfs, string memory _socialThread) public isMember currentlyRaising returns (bool) {
    Proposal memory newProp = Proposal(_title, _idea, _ipfs, _socialThread, msg.sender, proposalStatus.ACTIVE, address(0));
    proposals.push(newProp);
    return true;
  }

  // ERR: cannot create dynamic size arrays
  // function getAllProposals() public view returns (string[] memory, string[] memory, string[] memory, string[] memory, address[] memory, string[] memory) {
  //   uint length = proposals.length;
  //   string[] memory titles = string[length];
  //   string[] memory ideas = string[length];
  //   string[] memory ipfs = string[length];
  //   string[] memory socialThreads = string[length];
  //   address[] memory creators = address[length];
  //   proposalStatus[] memory statuses = proposalStatus[length];

  //   for(uint i = 0; i < proposals.length; i++){
  //     titles.push(proposals[i].title);
  //     ideas.push(proposals[i].idea);
  //     ipfs.push(proposals[i].ipfs);
  //     socialThreads.push(proposals[i].socialThread);
  //     creators.push(proposals[i].creator);
  //     statuses.push(proposals[i].status);
  //   }

  //   return (titles, ideas, ipfs, socialThreads, creators, statuses);
  // }

  function getNumOfProposals() public view returns (uint) {
    return proposals.length;
  }

  function getProposalDetails(uint _proposalId) public view returns (string memory, string memory, string memory, string memory, address, proposalStatus, address) {
    Proposal memory prop = proposals[_proposalId];
    return (prop.title, prop.idea, prop.ipfs, prop.socialThread, prop.creator, prop.status, prop.disputor);
  }

  function getVotingPower(uint _lockedTokens) internal returns (uint) {
    if(_lockedTokens < 10) {
      return 1;
    } else if(_lockedTokens < 50) {
      return 2;
    } else if(_lockedTokens < 250) {
      return 3;
    } else if(_lockedTokens < 1000) {
      return 4;
    } else {
      return 5;
    }
  }

  function voteForProposal(int _proposalId, uint _lockedTokens) public payable isMember currentlyRaising returns (bool) {
    voteBank[msg.sender] += _lockedTokens;
    proposalVotes[_proposalId] += getVotingPower(_lockedTokens);
    return true;
  }

  function disputeProposal(uint _proposalId) public payable currentlyRaising returns (bool) {
    require(proposals[_proposalId].status == proposalStatus.ACTIVE);
    require(msg.value >= minDisputeCollateral);
    proposals[_proposalId].status = proposalStatus.DISPUTED;
    address payable sender = payable(msg.sender);
    sender.transfer((msg.value - 1) * 1 ether);
  }

  // string memory, string memory, string memory, string memory, address memory, string memory
  function pickTopProposal() internal view onlyOwner currentlyRaising returns(int) {
    int winnerPropsalId;
    int maxSupport = -1;
    for(int i = -1; i < int(proposals.length); i++) {
      if(int(proposalVotes[i]) > maxSupport && proposals[i].status == proposalStatus.ACTIVE) {
        maxSupport = int(proposalVotes[i]);
        winnerPropsalId = i;
      }
    }
    return winnerPropsalId;
  }

  function breakOrMake() external onlyOwner currentlyRaising returns(bool) {
    if(totalVoteTokens < (raiseGoal / 4)){
      disbandDAO();
      return false;
    } 
    int topProposal = pickTopProposal();
    if(topProposal == -1) {
      disbandDAO();
      return false;
    }

    makeBoardDAO(uint(topProposal));
    return true;
  }

  function disbandDAO() internal onlyOwner currentlyRaising {
    address payable curr;
    for(uint i = 0; i < depositors.length; i++) {
      curr = payable(depositors[i]);
      curr.transfer(depositorBank[depositors[i]] * 1 ether);
    }
  }

  function makeBoardDAO(uint _proposalId) internal onlyOwner currentlyRaising {
    // TODO: make the BoardDAO - send all MATIC to it, get back a token
  }
}
