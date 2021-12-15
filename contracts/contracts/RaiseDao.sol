// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Token.sol";
import "./BoardDao.sol";

contract RaiseDao {
  string public campaignName;
  address public  _owner;
  address public invesDao;
  Token public companyToken;

  uint public raiseGoal;
  uint public yetToBeRaised;
  DAOStatus stageOfDAO;
  uint public constant votingPeriod = 2 weeks;
  uint public constant disputablePeriod = 1 weeks;
  uint public constant minDisputeCollateral = 1 ether;
  uint public timeOfCreation;

  enum DAOStatus {VOTING, EXECUTING, DISBANDED}
  enum proposalStatus {ACTIVE, DISPUTED, ACCEPTED}

  mapping (address => uint) depositorBank;
  address[] depositors;

  struct Proposal {
    string title;
    string idea;
    string ipfs;
    string tokenName;
    string tokenSymbol;
    string socialThread;
    address creator;
    proposalStatus status;
    address disputor;
    uint daoOwnership;
    uint creatorOwnership;
  }
  
  Proposal[] public proposals;

  mapping (address => uint) public voteBank;
  address[] public voters;

  uint public totalVoteTokens;

  mapping (int => uint) public proposalVotes;

  event proposalCreated(address _from, uint _proposalId);
  event voteReceived(address _from, int _proposalId);
  event newMember(address _from, uint _amount);
  event proposalDisputed(address _from, uint _proposalId);

  constructor(
    string memory _daoThemeName,
    string memory _daoTokenName,
    string memory _daoTokenSymbol,
    uint _raiseGoal
  )  {
    campaignName = _daoThemeName;
    _owner = msg.sender;
    timeOfCreation = block.timestamp;
    invesDao = msg.sender;
    companyToken = new Token(_daoTokenName, _daoTokenSymbol, _raiseGoal);
    raiseGoal = _raiseGoal;
    yetToBeRaised = _raiseGoal;
    stageOfDAO = DAOStatus.VOTING;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner);
    _;  
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
    companyToken.approve(msg.sender, msg.value); 
    emit newMember(msg.sender, msg.value);
  }

  function createProposal(string memory _title, string memory _idea, string memory _ipfs, string memory _tokenName, string memory _tokenSymbol, string memory _socialThread, uint _daoOwnership, uint _creatorOwnership) public isMember currentlyRaising returns (bool) {
    require(_daoOwnership == 49, "Only 49-49-2 structure is allowed currently");
    require(_creatorOwnership == 49, "Only 49-49-2 structure is allowed currently");
    proposals.push(Proposal(_title, _idea, _ipfs, _tokenName, _tokenSymbol, _socialThread, msg.sender, proposalStatus.ACTIVE, address(0), _daoOwnership, _creatorOwnership));
    emit proposalCreated(msg.sender, proposals.length - 1);
    return true;
  }

  function getNumOfProposals() public view returns (uint) {
    return proposals.length;
  }

  function getProposalDetails(uint _proposalId) public view returns (string memory, string memory, string memory, string memory, string memory, string memory, address, proposalStatus, address) {
    Proposal memory prop = proposals[_proposalId];
    return (prop.title, prop.idea, prop.ipfs, prop.tokenName, prop.tokenSymbol, prop.socialThread, prop.creator, prop.status, prop.disputor);
  }

  function voteForProposal(int _proposalId, uint _lockTokens) public isMember currentlyRaising returns (bool) {
    require(companyToken.balanceOf(msg.sender) >= _lockTokens, "Insufficient DAO tokens");
    companyToken.decreaseAllowance(msg.sender, _lockTokens);
    voteBank[msg.sender] += _lockTokens;
    voters.push(msg.sender);
    proposalVotes[_proposalId] += _lockTokens;
    emit voteReceived(msg.sender, _proposalId);
    return true;
  }

  function disputeProposal(uint _proposalId) public payable currentlyRaising returns (bool) {
    require(proposals[_proposalId].status == proposalStatus.ACTIVE);
    require(msg.value >= minDisputeCollateral);
    proposals[_proposalId].status = proposalStatus.DISPUTED;
    address payable sender = payable(msg.sender);
    sender.transfer(msg.value / 2);
    emit proposalDisputed(msg.sender, _proposalId);
    return true;
  }

  // string memory, string memory, string memory, string memory, address memory, string memory
  function pickTopProposal() internal view onlyOwner currentlyRaising returns(int) {
    int winnerPropsalId = -1;
    int maxSupport = int(proposalVotes[-1]);
    for(int i = 0; i < int(proposals.length); i++) {
      if(int(proposalVotes[i]) > maxSupport && proposals[uint(i)].status == proposalStatus.ACTIVE) {
        maxSupport = int(proposalVotes[i]);
        winnerPropsalId = i;
      }
    }
    return winnerPropsalId;
  }

  function makeOrBreak() external onlyOwner currentlyRaising returns(bool) {
    // if(totalVoteTokens < (raiseGoal / 4)){
    //   disbandDAO();
    //   return false;
    // } 
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
      curr.transfer( ((depositorBank[depositors[i]]) * 100) / totalClaim);
    }
    stageOfDAO = DAOStatus.DISBANDED;
  }

  function makeBoardDAO(uint _proposalId) internal onlyOwner currentlyRaising {
    proposals[_proposalId].status = proposalStatus.ACCEPTED;
    board = new BoardDao(proposals[_proposalId].creator, invesDao, proposals[_proposalId].daoOwnership, proposals[_proposalId].creatorOwnership, 2, proposals[_proposalId].tokenName, proposals[_proposalId].tokenSymbol, address(companyToken));
    boardTokenAddress = board.getTokenAddress();
    boardToken = IERC20(boardTokenAddress);
    stageOfDAO = DAOStatus.EXECUTING;
    resetVoteBank();
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
  bool private boardMinted = false;

  modifier boardProposalUpForVoting (uint _proposalId) {
    require(boardProposals[_proposalId].status == BoardProposalStatus.VOTING);
    _;
  }

  modifier boardProposalAccepted (uint _proposalId) {
    require(boardProposals[_proposalId].status == BoardProposalStatus.ACCEPTED);
    _;
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

  modifier boardNotMinted() {
    require(boardMinted==false, "board already minted");
    _;
  }

  function mintBoard() public onlyOwner boardNotMinted {
    board.mintBoardVotes();
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
    require(stageOfDAO != DAOStatus.DISBANDED);
    _;
  }

  function getRaiseDaoTokenAddress() public view isNotDisbanded returns(address) {
    return address(companyToken);
  }

  function getBoardDaoTokenAddress() public view isNotDisbanded currentlyExecutiveBoard returns(address) {
    return boardTokenAddress;
  }

  function getRaiseDaoDetails() public view returns(string memory, uint, uint, DAOStatus, string memory, string memory) {
    return (campaignName, raiseGoal, yetToBeRaised, stageOfDAO, companyToken.name(), companyToken.symbol());
  }
  
}
