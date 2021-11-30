// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

/**
 * @title Book
 * @dev pseudocode
 */
contract Book {

    // function bet(string winningTeam, string losingTeam, string gameTime) public payable beforeGameTime(gameTime) {
    //     // add a bet to the betList
    // }

    // function getResult(string teamName1, string teamName2, string gameTime) public payable afterGameTime(gameTime) {
    //     // get winningTeam from Provable
    //     // other team is losingTeam

    //     // Collect all losing bets into winnings account.  Tally all winning bets.
    //     // uint sumOfWinningBets = 0;
    //     // for each bet in betList {
    //         // if the teams and gameTime are a fuzzy match {
    //             // if the bet is for the losing team {
    //                 // put ether into winnings account
    //             //} else {
    //                 //sumOfWinningBets += bet.value;
    //             //}
    //         //}
    //     //}
    //     // uint sumOfLosingBets = winnings.value;

    //     // Take profit off the top
    //     // winnings.pay(houseAccount, sumOfWinningBets * 0.01)
    //     // sumOfWinningBets *= 0.99;
        
    //     // Pay all winning bets proportionally
    //     // for each bet in betList {
    //         // if the teams and gameTime are a fuzzy match {
    //             // if the bet is for the winning team {
    //                 // put ether into better account proportionally
    //                 // winnings.pay(bet.account, (bet.value / sumOfWinningBets) * sumOfLosingBets);
    //             //}
    //         //}
    //     //}
    // }

    // modifier beforeGameTime(string gameTime) {
    //     // asserts that it is before game time
    //     // note: need oracle?
    // }

    // modifier afterGameTime(string gameTime) {
    //     // asserts that it is 24 hours after game time
    // }

    // /*
    //     Other thoughts:
    //     keep track of games?
    //     save resources by not iterating through all contracts?
    // */

}