// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Token.sol";
import "./RaiseDao.sol";
import "./BoardDao.sol";

contract InvesDao {
  address _owner;
  uint constant maxSupply = (10 ** 10) * (1 ether);
  uint supplyRemaining = (10 ** 10) * (1 ether);
  Token iDAO;
  uint timeOfCreation;
  
  constructor()  {
    timeOfCreation = block.timestamp;
    iDAO = new Token("InvesDao", "iDAO", maxSupply);
    iDAO.transfer(msg.sender, 100 ether);
    _owner = (msg.sender);
  }

  address[] raiseCampaigns;
  event TokenSwapped(address, uint);

  modifier membershipAvailable() {
    require(supplyRemaining > 0);
    _;
  }

  modifier isMember () {
    require(iDAO.balanceOf(msg.sender) > 1 ether);
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner);
    _;
  }

  function applyForMembership() payable public membershipAvailable {
    require(msg.value <= supplyRemaining, "Not enough tokens available");
    supplyRemaining -= msg.value;
    iDAO.transfer(msg.sender, msg.value); 
    emit TokenSwapped(msg.sender, msg.value);
  }

  function createRaiseCampaign(string memory _tokenName, string memory _tokenSymbol, uint _raiseGoal) public membershipAvailable {
    RaiseDao newCampaign = new RaiseDao(_tokenName, _tokenSymbol, _raiseGoal);
    raiseCampaigns.push(address(newCampaign));
  }

}
