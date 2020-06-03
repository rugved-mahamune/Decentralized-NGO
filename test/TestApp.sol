pragma solidity >=0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Primary.sol";
import "../contracts/NGO.sol";
import "../contracts/Entity.sol";

contract TestApp {
    function testInititionInvalid() public {
        NGO ngoContract = NGO(DeployedAddresses.NGO());
        ngoContract.startInitiative("Food for seniors-reg001", "Helping the Unemployed citizens in Pandemic", 500000, "food", true);

    }
    function testNGOCreation() public {
        NGO ngoContract = NGO(DeployedAddresses.NGO());
        ngoContract.addNewNGO("Old Age India", "old-age");
    }

    function testGetList() public {
        Primary primaryC = Primary(DeployedAddresses.Primary());
        uint op = primaryC.getActiveInitiatives().length;
        Assert.equal(op, 0, "No Initatives found");
    }
}