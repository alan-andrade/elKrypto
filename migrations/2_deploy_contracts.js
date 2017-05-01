var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");
var PoE = artifacts.require("./ProofOfExistence1.sol");
var PoE2 = artifacts.require("./ProofOfExistence2.sol");
var PoE3 = artifacts.require("./ProofOfExistence3.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);
  deployer.deploy(PoE);
  deployer.deploy(PoE2);
  deployer.deploy(PoE3);
};
