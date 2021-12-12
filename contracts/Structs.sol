// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Structs {
    enum DAOStatus {VOTING, EXECUTING, DISBANDED}
    enum proposalStatus {ACTIVE, DISPUTED, ACCEPTED}

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

}