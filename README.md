# Decentralized-NGO
A De-Centralized NGO for Fund Raising and Entity Voting Mechanism for Tender.

truffle compile

truffle migrate

truffle console

let primary = await Primary.deployed()
let entity = await Entity.deployed()
let ngo = await NGO.deployed()

primary.setNGOContract(ngo.address)
primary.setEntityContract(entity.address)


change address 
ngo.addNewNGO("Old Age India", "old-age",{from: accounts[1]})
ngo.addNewNGO("Educate rural India", "education",{from: accounts[2]})

ngo.startInitiative("Food for seniors-reg001", "Helping the Unemployed citizens in Pandemic", "500000", "food", true, {from: accounts[1]})
ngo.startInitiative("Tech for Rural India-reg002", "Video conferencing app for rural area", "1000000", "IT", true, {from: accounts[2]})
ngo.startInitiative("Education for seniors-reg001", "Employment training for old aged", "300000", "food", true, {from: accounts[1]})

ngo.getNGOsCount()
