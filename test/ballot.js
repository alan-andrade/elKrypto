var MetaCoin = artifacts.require("./MetaCoin.sol");
var Ballot = artifacts.require("./Ballot.sol");

contract('Ballot', function(accounts) {
  it("should have no proposals voted on", function() {
    return Ballot.deployed().then(function(instance) {
      return instance.getProposalVotes.call(0);
    }).then(function(proposalVotes) {
      assert.equal(proposalVotes.valueOf(), 0, "The first proposal didn't have 0 votes");
    });
  });

  it("should register a vote", function() {
    var ballot;

    var proposal = 1;

    var voter = accounts[0];

    return Ballot.deployed().then(function(instance) {
      ballot = instance;
      return ballot.giveRightToVote(voter);
    }).then(function() {
      return ballot.getProposalVotes.call(proposal);
    }).then(function(num_votes) {
      assert.equal(num_votes.valueOf(), 0, "Initial votes are not zero");
    }).then(function() {
      return ballot.vote(proposal, {from: voter});
    }).then(function() {
      return ballot.getProposalVotes.call(proposal);
    }).then(function(num_votes) {
      assert.equal(num_votes.valueOf(), 1, "The vote did not register");
    });
  });


  it("should not vote if the user is ineligible", function() {
    var metacoin;
    var ballot;

    var chairperson = accounts[0];
    var voter = accounts[1];

    var initial_votes;
    var ending_votes;

    return Ballot.deployed().then(function(instance) {
      ballot = instance;
      return ballot.getProposalVotes.call(0);
    }).then(function(num_votes) {
      initial_votes = num_votes.valueOf();
      return ballot.vote(0, {from: voter});
    }).then(function() {
      return ballot.getProposalVotes.call(0);
    }).then(function(num_votes) {
      // User should not vote unless we give the user the right to vote
      assert.equal(num_votes.valueOf(), initial_votes, "User ended up voting");
    }).then(function() {
      return ballot.giveRightToVote(voter);
    }).then(function() {
      return ballot.vote(0, {from: voter});
    }).then(function() {
      return ballot.getProposalVotes.call(0);
    }).then(function(num_votes) {
      assert.equal(num_votes.valueOf(), initial_votes, "User ended up voting");
    });
  });

  it("should cost the voter the payment cost", function() {
    var metacoin;
    var ballot;

    var initial_balance;
    var ending_balance;

    var chairperson = accounts[0];
    var voter = accounts[2];

    return Ballot.deployed().then(function(instance) {
      ballot = instance;
      return MetaCoin.deployed();
    }).then(function(instance) {
      metacoin = instance;
      //We need to set up our account so that it can vote with the right funds
      return metacoin.sendCoin(voter, 30, {from: accounts[0]});
    }).then(function() {
      return metacoin.getBalance.call(voter);
    }).then(function(balance) {
      initial_balance = balance.toNumber();
      return ballot.giveRightToVote(voter);
    }).then(function() {
      return ballot.vote(0, {from: voter});
    }).then(function() {
      return metacoin.getBalance.call(voter);
    }).then(function(balance) {
      ending_balance = balance.toNumber();
      return ballot.getVotingCost.call();
    }).then(function(voting_cost) {
      assert.equal(initial_balance - ending_balance, voting_cost.toNumber(), "Vote didn't properly deduct from user's metacoin");
    });
  });
});
