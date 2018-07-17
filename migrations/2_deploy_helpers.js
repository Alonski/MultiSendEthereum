var Escapable = artifacts.require("./giveth-common-contracts/contracts/Escapable.sol");

module.exports = function(deployer) {
  deployer.deploy(Escapable, 0x839395e20bbB182fa440d08F850E6c7A8f6F0780, 0x8Ff920020c8AD673661c8117f2855C384758C572);
};
