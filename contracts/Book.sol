// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.5.0 < 0.6.0;
pragma experimental ABIEncoderV2; // allows multidimensional array returns with old solc needed for ProvableAPI

import "./provableAPI.sol";

/**
 * @title Book
 * @author Phil Chapin
 * @notice You can use this contract for only the most basic simulation
 * @dev This is a proof-of-concept with security flaws; do not use on mainnet.
 */
contract Book is usingProvable {

    enum State {
        Pending,
        Won,
        Lost,
        Tied,
        Paid,
        Error
    }

    struct Bet {
        address payable maker;
        bytes32 winningTeam;
        bytes32 losingTeam;
        uint gameTime;
        uint amount;
        State state;
    }

    struct Query {
        bytes32 teamName1;
        bytes32 teamName2;
        uint gameTime;
        bool pending;
    }

    Bet[] bets;
    address payable owner;
    mapping (bytes32 => Query) public pendingQueries;

  /* 
   * Events
   */
    
    event LogNewProvableQuery(string description);
    event LogNewGameResult(string winningTeam);

  /* 
   * Modifiers
   */

    /// @notice Asserts that it is now before game time
    modifier beforeGameTime(uint gameTime) {
        require (now < gameTime);
        _;
    }

    /// @notice Asserts that it is now after game time
    modifier afterGameTime(uint gameTime) {
        require (now > gameTime);
        _;
    }

  /* 
   * Public functions
   */

    /// @notice Public constructor
    /// @dev Sets the owner
    constructor() public payable {
        // Set the owner to the transaction sender
        owner = msg.sender;
    }

    /// @notice Add a bet to the betList
    /// @dev If you want to debug, remove the requirement beforeGameTime(...)
    /// @param winningTeam The name of the team the bettor wants to win
    /// @param losingTeam The name of the team the bettor wants to lose
    /// @param gameTime The UNIX timestamp for the game's date and start time
    function bet(bytes32 winningTeam, bytes32 losingTeam, uint gameTime) public payable beforeGameTime(gameTime) {
        // add a bet to the betList
        bets.push(Bet(msg.sender, winningTeam, losingTeam, gameTime, msg.value, State.Pending));
    }

    /// @notice Returns all bets past and future
    /// @return Array of bets
    function getBets() public view returns (Bet[] memory) {
        return bets;
    }

    /// @notice Triggers payments by querying Provable => WolframAlpha for a game winner
    /// @dev This function exits and we wait for the __callback(...) to fire.  No state can be passed so we save it in pendingQueries.
    /// @param teamName1 The name of one of the teams
    /// @param teamName2 The name of the other team
    /// @param gameTime The UNIX timestamp for the game's date and start time
    function triggerPayments(bytes32 teamName1, bytes32 teamName2, uint gameTime) public afterGameTime(gameTime) {
        emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
        // TODO?: would like to specify human readable date of UNIX gameTime for Wolfram query
        bytes32 queryId = provable_query("WolframAlpha", strConcat("winner game result of ", bytes32ToString(teamName1), " vs ", bytes32ToString(teamName2)));
        pendingQueries[queryId] = Query(teamName1, teamName2, gameTime, true);
    }

    /// @notice Callback for getting winningTeam from Provable
    /// @dev No state can be passed so we get it from pendingQueries.
    /// @param _myid The queryId
    /// @param _result The name of the winning team
    function __callback(bytes32 _myid, string memory _result) public {
        emit LogNewGameResult(_result);
        require(msg.sender == provable_cbAddress());
        require (pendingQueries[_myid].pending == true);
        bytes32 winningTeam = stringToBytes32(_result);
        // TODO: some team names are concatted
        emit LogNewGameResult(_result);
        // other team is losingTeam
        bytes32 losingTeam;
        if (pendingQueries[_myid].teamName1 == winningTeam) {
            losingTeam = pendingQueries[_myid].teamName2;
        } else {
            losingTeam = pendingQueries[_myid].teamName1;
        }
        uint gameTime = pendingQueries[_myid].gameTime;
        delete pendingQueries[_myid];

        // Collect all losing bets into winnings account.  Tally all winning bets.
        uint sumOfWinningBets = 0;
        uint sumOfLosingBets = 0;
        //Bet[] memory winners = Bet[];
        //Bet[] memory losers = Bet[];
        // find all bets that match exactly
        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].state == State.Pending && bets[i].gameTime == gameTime) {
                if (bets[i].winningTeam == winningTeam && bets[i].losingTeam == losingTeam) {
                    // winning bet
                    bets[i].state = State.Won;
                    sumOfWinningBets += bets[i].amount;
                    //winners.push(bets[i]);
                } else if (bets[i].winningTeam == losingTeam && bets[i].losingTeam == winningTeam) {
                    // losing bet
                    bets[i].state = State.Lost;
                    sumOfLosingBets += bets[i].amount;
                    //losers.push(bets[i]);
                }
                // else it's a different game still pending
            }
        }
        
        // Take profit off the top
        if (sumOfWinningBets != 0 || sumOfLosingBets != 0) {
            uint ownerProfit = (sumOfWinningBets + sumOfLosingBets) / 100;
            owner.transfer(ownerProfit);
            sumOfWinningBets = sumOfWinningBets / 100 * 99;
            sumOfLosingBets = sumOfLosingBets / 100 * 99;
            // TODO: consider rounding errors a-la Superman 2?
        }

        // Pay all winning bets proportionally
        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].state == State.Won && bets[i].gameTime == gameTime && bets[i].winningTeam == winningTeam && bets[i].losingTeam == losingTeam) {
                // winners get back 99% of (their bet plus their percentage of the losing bets)
                bets[i].maker.transfer(sumOfWinningBets * (bets[i].amount / sumOfWinningBets) + sumOfLosingBets * (bets[i].amount / sumOfWinningBets));
                bets[i].state = State.Paid;
            }
        }
    }

  /* 
   * Helper functions
   */

    /// @notice Converts bytes32 to a string
    /// @dev Thanks https://ethereum.stackexchange.com/questions/2519/how-to-convert-a-bytes32-to-string
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    /// @notice Converts a string to bytes32
    /// @dev Thanks https://ethereum.stackexchange.com/questions/9142/how-to-convert-a-string-to-bytes32
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

}