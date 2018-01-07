// Imports:
var MultiSend = artifacts.require('./MultiSend.sol');

module.exports = function(deployer) {
  deployer.deploy(MultiSend);
};