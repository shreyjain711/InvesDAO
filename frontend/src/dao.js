import web3 from './web3';

const address = "0x515Ee81d12Fddd70461e2eB17a3a8E24bF48D64b";

const abi = [
    {
    "constant": true,
    "inputs": [],
    "name": "manager",
    "outputs": [
    {
    "name": "",
    "type": "address"
    }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
    },
    {
    "constant": false,
    "inputs": [],
    "name": "pickWinner",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
    },
    {
    "constant": true,
    "inputs": [],
    "name": "getPlayers",
    "outputs": [
    {
    "name": "",
    "type": "address[]"
    }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
    },
    {
    "constant": false,
    "inputs": [],
    "name": "enter",
    "outputs": [],
    "payable": true,
    "stateMutability": "payable",
    "type": "function"
    },
    {
    "constant": true,
    "inputs": [
    {
    "name": "",
    "type": "uint256"
    }
    ],
    "name": "players",
    "outputs": [
    {
    "name": "",
    "type": "address"
    }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
    },
    {
    "inputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
    }
    ];

// @ts-ignore
export default new web3.eth.Contract(abi, address);