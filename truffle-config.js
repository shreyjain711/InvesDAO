const path = require("path");
const HDWalletProvider = require("@truffle/hdwallet-provider")
require('dotenv').config(); // Load .env file

module.exports = {
    networks: {
        // For Ganache, your personal blockchain
        development: {
            host: "127.0.0.1",     // Localhost (default: none)
            port: 8545,            // Standard Ethereum port 
            network_id: "*",       // Any network (default: none)
        },
        matic: {
            provider: () => new HDWalletProvider(process.env.MNEMONIC, 
            `https://rpc-mumbai.maticvigil.com/`),
            network_id: 80001,
            confirmations: 2,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 6000000,
            gasPrice: 10000000000,
          },
    },
    contracts_directory: './contracts/',
    contracts_build_directory: path.join(__dirname, "client/src/contracts"),
    compilers: {
      solc: {
          version: "0.8.10",
          evmMachine: "byzantium",
          optimizer: {
              enabled: true,
              runs: 200
          }
      }
    }
}
