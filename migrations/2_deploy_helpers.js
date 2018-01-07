var Escapable = artifacts.require("./giveth-common-contracts/contracts/Escapable.sol");

module.exports = function(deployer) {
  deployer.deploy(Escapable);
};
