import Web3 from "web3";
import { use } from '@maticnetwork/maticjs'
import { Web3ClientPlugin } from '@maticnetwork/maticjs-web3'

// install ethers plugin
use(Web3ClientPlugin);

window.ethereum.enable();

const web3 = new Web3(Web3.givenProvider);
export default web3;
