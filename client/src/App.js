import React, { Component } from "react";
import RaiseDao from "./contracts/RaiseDao.json";
import BoardDao from "./contracts/BoardDao.json";
import web3 from "./getWeb3";

import "./App.css";
import CreateRaiseDaoCardLayout from  "./components/RaiseDaoCard.js"

class App extends Component {
  state = { storageValue: 0, web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      // const web3 = await web3();

      // Use web3 to get the user's accounts.
      // const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      // const addresses = ['0x444816C8254D4A738D28622390A4f5A523ec604E', '0x716F58B8310EceEA95Eb35d29CB4d97753C59bA3 ', '0x66Bc10De618dAF267ca24a8FC1AeeBF2ced70030'];
      const addresses = ['0x61A9E1fc10593fE681934C37d21599931441CBC3', '0xaEF1780E0Bc5a9164ABdf4c3b812075670EA713F', '0x12d0b8170F8E6cE1285ca8DECB041a3f40DdEf3f'];
      const instances = [];
      for (let i in addresses){
        const instance = await new web3.eth.Contract(RaiseDao.abi, addresses[i])
        instances.push(instance);
      }

      // instances[0].methods.applyForMembership




      
      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ instances }, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  runExample = async () => {
    const { instances } = this.state;

    const responses = [];
    for(let i in instances){
      // await contract.methods.getRaiseDaoDetails(5).send({ from: accounts[0] });
      // Get the value from the contract to prove it worked.
      const response = await instances[i].methods.getRaiseDaoDetails().call();
      const numProposals = await instances[i].methods.getNumOfProposals().call();
      response[6] = numProposals;
      responses.push(response);
    }

    // Update state with the result.
    this.setState({ raiseDaos: responses });
    this.setState({ web3: web3 });
    console.log(responses);
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <div>
          <h1>InvesDAO!</h1>
        </div>
        <CreateRaiseDaoCardLayout alldaos={this.state.raiseDaos} />
      </div>
    );
  }
}

export default App;
