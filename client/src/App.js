import React, { Component } from "react";
import SimpleStorageContract from "./contracts/SimpleStorage.json";
import BookContract from "./contracts/Book.json";
import getWeb3 from "./getWeb3";

import "./App.css";

class App extends Component {
  constructor(props) {
    super(props);
    this.state = { storageValue: "", web3: null, accounts: null, contract: null, winningTeam: "", losingTeam: "", gameTime: 0, amount: 0 };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = BookContract.networks[networkId];
      const instance = new web3.eth.Contract(
        BookContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance }, this.runExample);
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  runExample = async () => {
    const { accounts, contract, web3 } = this.state;

    const response = await contract.methods.getBets().call({gas: 6e6});
    let table = "<table>\n<tr><td>maker</td><td>winningTeam</td><td>losingTeam</td><td>gameTime</td><td>amount</td><td>state</td></tr>\n"; // lol dirty
    for (const bet of response) {
      table += "<tr><td>" + bet.maker + "</td><td>" + web3.utils.toAscii(bet.winningTeam) + "</td><td>" + web3.utils.toAscii(bet.losingTeam) + "</td><td>"
       + (new Date(bet.gameTime * 1000).toLocaleString()) + "</td><td>" + bet.amount + "</td><td>" + bet.state + "</td></tr>\n";
    }
    table += "</table>\n"

    // Update state with the result.
    this.setState({ storageValue: table });
  };
  
  handleSubmit(event) {
    alert('You put: ' + this.state.winningTeam);
    const { accounts, contract, web3 } = this.state;
    contract.methods.bet(web3.utils.asciiToHex(this.state.winningTeam), web3.utils.asciiToHex(this.state.losingTeam), this.state.gameTime).send({ from: accounts[0], value: this.state.amount, gas: 6e6});
    event.preventDefault();
  }

  handleChange(event) {
    this.setState({[event.target.name]: event.target.value});
  }

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Good to Go!</h1>
        <p>Your Truffle Box is installed and ready.</p>
        <h2>Smart Contract Example</h2>
        <form onSubmit={this.handleSubmit}>
          <p>
            Make a bet?
          </p>
          <label>
            Winning <a target="_blank" href="https://www.wolframalpha.com/input/?i=nfl+team&assumption=%7B%22C%22%2C+%22nfl+team%22%7D+-%3E+%7B%7B%22DataType%22%2C+%22NFL+teams%22%7D%7D">Team Name:</a>
            <input name="winningTeam" type="text" value={this.state.winningTeam} onChange={this.handleChange} />
          </label><br />
          <label>
            Losing Team Name:
            <input name="losingTeam" type="text" value={this.state.losingTeam} onChange={this.handleChange} />
          </label><br />
          <label>
            <a target="_blank" href="https://www.unixtimestamp.com/index.php">UNIX</a> Game Time:
            <input name="gameTime" type="text" value={this.state.gameTime} onChange={this.handleChange} />
          </label><br />
          <label>
            Bet amount in <a target="_blank" href="https://www.investopedia.com/terms/w/wei.asp">wei</a>:
            <input name="amount" type="text" value={this.state.amount} onChange={this.handleChange} />
          </label><br />
          <input type="submit" value="Submit" />
        </form>
        <p>
          Here is the "Book", the list of all bets in the blockchain (refresh page to update):
        </p>
        <div dangerouslySetInnerHTML={{__html: this.state.storageValue}} />
      </div>
    );
  }
}

export default App;
