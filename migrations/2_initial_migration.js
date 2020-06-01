
const primary = artifacts.require("Primary");
const ngo = artifacts.require("NGO");

module.exports = function(deployer) {
  deployer.deploy(primary);
};

module.exports = (deployer) => {
    deployer.deploy(primary).then(function() {
    deployer.deploy(ngo, primary.address)
    deployer.deploy(entity, primary.address)
    });
  };