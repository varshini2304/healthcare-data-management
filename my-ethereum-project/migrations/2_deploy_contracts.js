const Company = artifacts.require('Company');

module.exports = function(deployer) {
  deployer.deploy(Company, '0xea5247a7F18f58CDa1bEA645E98E9Dceb3BeE676'); // Replace '0x...' with the desired address
};