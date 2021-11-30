# blockchain-developer-bootcamp-final-project

Idea: A proof-of-concept that allows sports betting.

Summary:

- For simplicity, reducing scope to game winner / loser.
- Users predict the winner of a game to be played.
- Ledger is kept of bets made:
  - address Address
  - string PredictedWinningTeamName
  - string PredictedLosingTeamName
  - string GameTime
  - uint Amount
- The contract can call the offsite oracle [Provable](https://app.provable.xyz/home/test_query#V29sZnJhbUFscGhh:V2lubmVyIG9mIE5GTCBQYXRyaW90cyB2cyBGYWxjb25zIG9uIE5vdmVtYmVyIDE4IDIwMjE=) to get truths, for example: "Winner of NFL Patriots vs Falcons on November 18 2021"
  - This calls [WolframAlpha](https://www.wolframalpha.com/input/?i=Winner+of+NFL+Patriots+vs+Falcons+on+November+18+2021), which sources from https://sportradar.us/
- All betting should cease at the scheduled game time.
- Some time after the game ends, the contract will pull the winner and pay out rewards proportionally.  The "house" keeps 1% of winnings.
  - In the event there is not a winner on that date (tie game, cancelation, rescheduling for a different date, system error, or API timeout) all bets will be refunded ideally.