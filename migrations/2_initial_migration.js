
const primary = artifacts.require("Primary");
const ngo = artifacts.require("NGO");
const entity = artifacts.require("Entity");

module.exports = (deployer) => {
    deployer.deploy(primary);
    deployer.deploy(ngo, primary.address);
    deployer.deploy(entity, primary.address);
  };