// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address ownerDao;
    
    constructor(string memory _tokenName, string memory _tokenSymbol, uint _maxSupply) ERC20(_tokenName, _tokenSymbol) {
        _mint(msg.sender, _maxSupply * (10 ** uint256(decimals())));
        ownerDao = msg.sender;
    }
}