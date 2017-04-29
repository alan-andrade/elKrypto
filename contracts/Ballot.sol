pragma solidity ^0.4.4;

import "./ConvertLib.sol";
import "./MetaCoin.sol";

// This is just a simple example of a coin-like contract.
// It is not standards compatible and cannot be expected to talk to other
// coin/token contracts. If you want to create a standards-compliant
// token, see: https://github.com/ConsenSys/Tokens. Cheers!

contract Ballot {

  event PaidVoter(address indexed voter, uint256 _value);

  struct Voter {
    address sendAddress;
    bool voted;
    bool canVote;
    uint votedProposal;
  }

  struct Proposal {
    bytes32 name;
    uint voteCount;
  }

  address chairperson;
  MetaCoin public metacoin;
  uint constant votingCost = 2;
  bool ballotWinnered;

  // Error logging
  mapping(address => string) public voteErrors;

  // This declares a state variable that
  // stores a `Voter` struct for each possible address.
  mapping(address => Voter) public voters;
  mapping(uint => address) public voterIndex;
  uint voterCount;

  // A dynamically-sized array of `Proposal` structs.
  Proposal[] proposals;

  // A list of winners when the ballot is winnered.
  Voter[] winners;

  // Constructor for our Ballot requires a list of strings pertaining to each
  // proposal in our Ballot
  function Ballot(bytes32[] proposalNames, address metacoinAddress) {
    chairperson = msg.sender;
    metacoin = MetaCoin(metacoinAddress);
    ballotWinnered = false;

    for(uint i = 0; i < proposalNames.length; i++) {
      proposals.push( Proposal({ name: proposalNames[i], voteCount: 0 }) );
    }
  }

  function getVotingCost() returns(uint) {
    return votingCost;
  }

  function giveRightToVote(address voter) {
    if (msg.sender != chairperson || voters[voter].voted ) return;
    voters[voter].canVote = true;
  }

  function vote(uint8 proposal) {
    Voter voter = voters[msg.sender];
    if (!voter.canVote || voter.voted) {
      voteErrors[msg.sender] = "NotEligibleToVote";
      return;
    } else if (proposal >= proposals.length) {
      voteErrors[msg.sender] = "ProposalOutOfBounds";
      return;
    } else if (!metacoin.transferCoin(msg.sender, this, votingCost)) {
      voteErrors[msg.sender] = "InsufficientVotingFunds";
      return;
    } else if (ballotWinnered) {
      voteErrors[msg.sender] = "BallotIsAlreadyWinnered";
      return;
    } else {
      // We want to proceed since our transaction went through
      proposals[proposal].voteCount += 1;
      voterCount += 1;
      voterIndex[voterCount] = msg.sender;
      voter.voted = true;
    }
  }

  function getProposalVotes(uint proposal) returns(uint) {
    return proposals[proposal].voteCount;
  }

  function getVoteError(address voter) returns(string) {
    return voteErrors[voter];
  }

  function winnerBallot() {
    // Collect the winning voters for the ballot;
    address[] winners;
    getWinners(winners);

    // Pay the winners
    //payWinners();

    // Set ballot as winnered
    ballotWinnered = true;
  }

  function payWinners(address[] winners) {
    // For each of our winners, disperse the meta coins
    // to the voters who voted correctly
    uint ballotBalance = metacoin.getBalance(this);
    uint winnerBalance = winners.length * 2;
    uint dividendBalance = ballotBalance - winnerBalance;

    address voter;

    for(uint i = 0; i < winners.length; i++) {
      voter = winners[i];
      uint sendAmount = 2;
      if (dividendBalance > 0) {
        sendAmount += 1;
        dividendBalance -= 1;
      }
      if (metacoin.transferCoin(this, voter, sendAmount)) {
        PaidVoter(voter, sendAmount);
      }
    }
  }

  // Get our winners
  function getWinners(address[] winners) {
    uint winningProposal = getWinningProposal();
    uint winnerIndex = winners.length;

    for(uint i = 0; i < voterCount; i++) {
      address voterAddr = voterIndex[i];
      Voter voter = voters[voterAddr];
      if(voter.votedProposal == winningProposal) winners[winnerIndex] = voter.sendAddress;
    }
  }

  // Collect the winnning Proposal by iterating over all
  // proposals and finding the one with the most votes.
  function getWinningProposal() returns(uint) {
    uint maxVotes = 0;
    uint winningProposal;
    for(uint i = 0; i < proposals.length; i++) {
      Proposal proposal = proposals[i];
      if (proposal.voteCount > maxVotes) {
        maxVotes = proposal.voteCount;
        winningProposal = i;
      }
    }

    return winningProposal;
  }

  function getVoterCount() returns(uint) {
    return voterCount;
  }
}
