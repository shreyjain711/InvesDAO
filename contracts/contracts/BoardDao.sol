// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Token.sol";
import "./RaiseDao.sol";

contract BoardDao {
  address _owner;
  RaiseDao daoContract;
  address dao;
  address creator;
  address invesDao;

  address raiseDaoToken;
  
  mapping (address => uint) voteBank;

  Token boardToken;

  uint256 constant boardSize = 100;
  
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

  BoardProposal[] public proposals;

  constructor(
    address _creator,
    address _invesDao,
    uint _daoOwnership,
    uint _creatorOwnership,
    uint _invesDaoOwnership,
    string memory _tokenName,
    string memory _tokenSymbol,
    address _raiseDaoToken
  ) {
    _owner = msg.sender;
    daoContract = RaiseDao(msg.sender);
    dao = (msg.sender);
    invesDao = _invesDao;
    creator = _creator;
    boardToken = new Token(_tokenName, _tokenSymbol, 100);
    voteBank[dao] = _daoOwnership;
    voteBank[_creator] = _creatorOwnership;
    voteBank[_invesDao] = _invesDaoOwnership;
    raiseDaoToken = _raiseDaoToken;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner);
    _;  
  }

  modifier hasNativeToken() {
    require(address(this).balance > 0);
    _;
  }

  function mintBoardVotes() external onlyOwner hasNativeToken {
    uint totalStake = voteBank[dao] + voteBank[creator] + voteBank[invesDao];
    boardToken.transfer(dao, ((voteBank[dao] * 100) / totalStake) * (1 ether));
    boardToken.transfer(dao, ((voteBank[creator] * 100) / totalStake) * (1 ether));
    boardToken.transfer(dao, ((voteBank[invesDao] * 100) / totalStake) * (1 ether));
  }

  modifier isBoardMember() {
    require(boardToken.balanceOf(msg.sender) > 0);
    _;
  }

  modifier proposalUpForVoting (uint _proposalId) {
    require(proposals[_proposalId].status == BoardProposalStatus.VOTING);
    _;
  }

  modifier proposalAccepted (uint _proposalId) {
    require(proposals[_proposalId].status == BoardProposalStatus.ACCEPTED);
    _;
  }

  function createProposal(string memory _title, string memory _purpose, address _recipient, uint _amountRequired) public isBoardMember {
    require(address(this).balance >= _amountRequired, "Not enough balance");
    proposals.push(BoardProposal(_title, _purpose, msg.sender, _recipient, _amountRequired, 0, BoardProposalStatus.VOTING));
    daoContract.createBoardProposal(_title, _purpose, _recipient, _amountRequired);
    
  }

  function voteForProposal(uint _proposalId, bool isInFavour) external payable isBoardMember proposalUpForVoting(_proposalId) {
    require(boardToken.balanceOf(msg.sender) > 0);
    if (isInFavour == true) {
      proposals[_proposalId].support += int(boardToken.balanceOf(msg.sender));
    } else {
      proposals[_proposalId].support -= int(boardToken.balanceOf(msg.sender));
    }
  }
  
  function decideOnProposal(uint _proposalId) external proposalUpForVoting(_proposalId) {
    require(msg.sender == proposals[_proposalId].creator);
    if (proposals[_proposalId].support > 0) {
      proposals[_proposalId].status = BoardProposalStatus.ACCEPTED;
      executeProposal(_proposalId);
    }
  }

  function executeProposal(uint _proposalId) internal proposalAccepted(_proposalId) {
    address payable recipient = payable(proposals[_proposalId].recipient);
    recipient.transfer(proposals[_proposalId].amountRequired);
  }

  function getTokenAddress() public view returns(address) {
    return address(boardToken);
  }

}