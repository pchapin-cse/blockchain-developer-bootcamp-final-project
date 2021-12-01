# blockchain-developer-bootcamp-final-project

Idea: A proof-of-concept that allows sports betting.


Summary:

- For simplicity, reducing scope to game winner / loser.
- Users predict the winner of a game to be played.
- Book is kept of bets made:
      address payable maker;
      bytes32 winningTeam;
      bytes32 losingTeam;
      uint gameTime;
      uint amount;
      State state;
- The contract can call the offsite oracle [Provable](https://app.provable.xyz/home/test_query#V29sZnJhbUFscGhh:V2lubmVyIG9mIE5GTCBQYXRyaW90cyB2cyBGYWxjb25zIG9uIE5vdmVtYmVyIDE4IDIwMjE=) to get truths, for example: "Winner of NFL Patriots vs Falcons on November 18 2021"
  - This calls [WolframAlpha](https://www.wolframalpha.com/input/?i=Winner+of+NFL+Patriots+vs+Falcons+on+November+18+2021), which sources from https://sportradar.us/
- All betting should cease at the scheduled game time.
- Some time after the game ends, a user will trigger the contract to pull the winner and pay out rewards proportionally.  The "house" (contract owner) keeps 1% of winnings.
  - In the event there is not a winner on that date (tie game, cancelation, rescheduling for a different date, system error, or API timeout) all bets will be refunded ideally.


### Directory Structure:

The directory structure follows that of [Truffle's React Box](https://www.trufflesuite.com/boxes/react)

    .
    ├── client                  # [React App](https://create-react-app.dev/docs/folder-structure/) for frontend
    ├── client/src              # React javascript code
    ├── client/src/contracts    # Contracts compiled by Truffle / Solidity and output here for use by frontend
    ├── contracts               # Solidity contract code
    ├── migrations              # Solidity code for migrations
    ├── test                    # Automated tests
    └── README.md


Instructions:

**1)** Fire up your favourite console & clone this repo somewhere:

__`❍ git clone https://github.com/pchapin-cse/blockchain-developer-bootcamp-final-project.git`__

**2)** Enter this directory & install dependencies:

__`❍ cd blockchain-developer-bootcamp-final-project && npm install`__

**3)** Launch Truffle (truffle-config.js defaults to port 9545 which can be changed if desired):

__`❍ npx truffle develop`__

**4)** Open a _new_ console in the same directory & spool up the ethereum-bridge matching Truffle's port:

__`❍ npx ethereum-bridge -a 9 -H 127.0.0.1 -p 9545 --dev`__

**5)** Once the bridge is ready & listening, go back to the first console with Truffle running & set the tests going!

__`❍ truffle(develop)> test`__

**6)** In a third new console, change into the client subdirectory and install dependencies:

__`❍ cd client && npm install`__

**7)** Then start the web client:

__`❍ npm run start`__

The frontend can be accessed [here](https://localhost:3000)
