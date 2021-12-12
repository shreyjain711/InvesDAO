// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Token.sol";
import "./Ownable.sol";
import "./BoardDao.sol";
import "./Structs.sol";

contract RaiseDao is Ownable {
  address invesDao;
  Token companyToken;

  uint raiseGoal;
  uint yetToBeRaised;
  Structs.DAOStatus stageOfDAO;
  uint constant votingPeriod = 2 weeks;
  uint constant disputablePeriod = 1 weeks;
  uint constant minDisputeCollateral = 100 ether;
  uint timeOfCreation;

  mapping (address => uint) depositorBank;
  address[] depositors;
  
  Structs.Proposal[] public proposals;

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
    timeOfCreation = block.timestamp;
    invesDao = msg.sender;
    companyToken = new Token(_daoTokenName, _daoTokenSymbol, _raiseGoal);
    raiseGoal = _raiseGoal;
    yetToBeRaised = _raiseGoal;
    stageOfDAO = Structs.DAOStatus.VOTING;
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
    require(stageOfDAO == Structs.DAOStatus.VOTING);
    _;
  }

  modifier currentlyExecutiveBoard() {
    require(stageOfDAO == Structs.DAOStatus.EXECUTING);
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

  function createProposal(string memory _title, string memory _idea, string memory _ipfs, string memory _tokenName, string memory _tokenSymbol, string memory _socialThread, uint _daoOwnership, uint _creatorOwnership) public isMember currentlyRaising returns (bool) {
    require(_daoOwnership == 49, "Only 49-49-2 structure is allowed currently");
    require(_creatorOwnership == 49, "Only 49-49-2 structure is allowed currently");
    proposals.push(Structs.Proposal(_title, _idea, _ipfs, _tokenName, _tokenSymbol, _socialThread, msg.sender, Structs.proposalStatus.ACTIVE, address(0), _daoOwnership, _creatorOwnership));
    return true;
  }

  function getNumOfProposals() public view returns (uint) {
    return proposals.length;
  }

  function getProposalDetails(uint _proposalId) public view returns (string memory, string memory, string memory, string memory, address, Structs.proposalStatus, address) {
    Structs.Proposal memory prop = proposals[_proposalId];
    return (prop.title, prop.idea, prop.ipfs, prop.socialThread, prop.creator, prop.status, prop.disputor);
  }

  function voteForProposal(int _proposalId, uint _lockedTokens) public payable isMember currentlyRaising returns (bool) {
    voteBank[msg.sender] += msg.value;
    voters.push(msg.sender);
    proposalVotes[_proposalId] += _lockedTokens;
    return true;
  }

  function disputeProposal(uint _proposalId) public payable currentlyRaising returns (bool) {
    require(proposals[_proposalId].status == Structs.proposalStatus.ACTIVE);
    require(msg.value >= minDisputeCollateral);
    proposals[_proposalId].status = Structs.proposalStatus.DISPUTED;
    address payable sender = payable(msg.sender);
    sender.transfer((msg.value - 1) * 1 ether);
    return true;
  }

  // string memory, string memory, string memory, string memory, address memory, string memory
  function pickTopProposal() internal view onlyOwner currentlyRaising returns(int) {
    int winnerPropsalId = -1;
    int maxSupport = int(proposalVotes[-1]);
    for(int i = 0; i < int(proposals.length); i++) {
      if(int(proposalVotes[i]) > maxSupport && proposals[uint(i)].status == Structs.proposalStatus.ACTIVE) {
        maxSupport = int(proposalVotes[i]);
        winnerPropsalId = i;
      }
    }
    return winnerPropsalId;
  }

  function makeOrBreak() external onlyOwner currentlyRaising returns(bool) {
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
    uint totalClaim = 0;
    for(uint i = 0; i < depositors.length; i++) {
      totalClaim += depositorBank[depositors[i]];
    }
    address payable curr;
    for(uint i = 0; i < depositors.length; i++) {
      curr = payable(depositors[i]);
      curr.transfer((depositorBank[depositors[i]] * 1 ether) / totalClaim);
    }
    stageOfDAO = Structs.DAOStatus.DISBANDED;
  }

  address boardTokenAddress;
  IERC20 public boardToken;
  enum BoardProposalStatus {VOTING, ACCEPTED, DECLINED}

  struct BoardProposal {
    string title;
    string purpose;
    address creator;
    address recipient;
    uint amountRequired;
    int support;
    BoardProposalStatus status;
  }

  BoardProposal[] public boardProposals;
  BoardDao private board;

  modifier boardProposalUpForVoting (uint _proposalId) {
    require(boardProposals[_proposalId].status == BoardProposalStatus.VOTING);
    _;
  }

  modifier boardProposalAccepted (uint _proposalId) {
    require(boardProposals[_proposalId].status == BoardProposalStatus.ACCEPTED);
    _;
  }

  function makeBoardDAO(uint _proposalId) internal onlyOwner currentlyRaising {
    proposals[_proposalId].status = Structs.proposalStatus.ACCEPTED;
    board = new BoardDao(proposals[_proposalId].creator, invesDao, proposals[_proposalId].daoOwnership, proposals[_proposalId].creatorOwnership, 2, proposals[_proposalId].tokenName, proposals[_proposalId].tokenSymbol, address(companyToken));
    boardTokenAddress = board.getTokenAddress();
    boardToken = IERC20(boardTokenAddress);
    stageOfDAO = Structs.DAOStatus.EXECUTING;
    resetVoteBank();
  }

  function resetVoteBank() internal onlyOwner {
    address payable curr;
    for(uint i = 0; i < voters.length; i++) {
      curr = payable(voters[i]);
      companyToken.transfer(curr, (depositorBank[depositors[i]]));
    }
    for(uint i = 0; i < voters.length; i++) {
      voteBank[voters[i]] = 0;
    } delete voters;
  }
  
  modifier isBoardDao() {
    require(msg.sender == address(board));
    _;
  }

  function createBoardProposal(string memory _title, string memory _purpose, address _recipient, uint _amountRequired) external isBoardDao currentlyExecutiveBoard {
    boardProposals.push(BoardProposal(_title, _purpose, msg.sender, _recipient, _amountRequired, 0, BoardProposalStatus.VOTING));
  }

  function voteForBoardProposal(uint _proposalId, bool isInFavour) public payable isMember currentlyExecutiveBoard boardProposalUpForVoting(_proposalId) returns (bool) {
    voteBank[msg.sender] += msg.value;
    voters.push(msg.sender);
    if (isInFavour == true){
      boardProposals[_proposalId].support += int(msg.value);
    } else {
      boardProposals[_proposalId].support -= int(msg.value);
    }
    return true;
  }

  function executeBoardProposal(uint _proposalId) public onlyOwner currentlyExecutiveBoard boardProposalUpForVoting(_proposalId) {
    if(boardProposals[_proposalId].support > 0) {
      boardProposals[_proposalId].status = BoardProposalStatus.ACCEPTED;
      board.voteForProposal(_proposalId, true);
    } else {
      boardProposals[_proposalId].status = BoardProposalStatus.DECLINED;
      board.voteForProposal(_proposalId, false);
    }
  }

  modifier isNotDisbanded() {
    require(stageOfDAO != Structs.DAOStatus.DISBANDED);
    _;
  }

  function getRaiseDaoTokenAddress() public view isNotDisbanded returns(address) {
    return address(companyToken);
  }

  function getBoardDaoTokenAddress() public view isNotDisbanded currentlyExecutiveBoard returns(address) {
    return boardTokenAddress;
  }

}
