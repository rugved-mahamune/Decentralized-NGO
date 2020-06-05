const Web3 = require('web3');
const NGO = require('../../build/contracts/NGO.json');
var ngoDeployed;
var ngoInstance;
var ngoList;
var contract = require("truffle-contract");

var provider = new Web3.providers.HttpProvider("http://localhost:7545");
const initate = () => {
    ngoInstance = contract(NGO);
    ngoInstance.setProvider(provider);

    ngoInstance.deployed().then(value => {
      ngoDeployed = value;
      return value.getNGOsCount();
    }).then(value => {
      ngoList = value;
      console.log(value);
      return value;
    });

/*
    ngoInstance.deployed().then(function(instance) {
    ngoDeployed = instance;
    return instance.getNGOsCount();
    }).then(function(result) {
        console.log(result);
        
    });*/
    return ngoDeployed;
}
const getAccounts = () => {
    console.log(accounts);
    if(networkData) {
      const ngo = web3.eth.Contract(NGO.abi, networkData.address)
      console.log(ngo);
    } else {
      window.alert('NGO contract not deployed to detected network.')
    }
    return ngo;
  }

const getNGO = () => {
    contract('NGO', (accounts) => {
        before(async () => {
          ngo = await NGO.deployed()
        })
      });
      
}
module.exports = {
    initate,
    getAccounts,
    getNGO,
    ngoInstance
  };