pragma solidity >= 0.5.0;

import "./Primary.sol";

contract Entity {

    address owner;
    address primaryContract;
    Primary primaryDeployed;
    struct EData {
        string name;
        uint served;
        string eType;
        bool blocked;
    }
    mapping (address => EData) private EntitiesList;

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
    //TO:DO check if the right msg.sender comes from primary
    modifier isEntity {
        require(
            !EntitiesList[msg.sender].blocked,
            "Only Legitimate Entities can request for contract"
        );
        _;
    }
    constructor(address _primary) public
    {
        owner = msg.sender;
        primaryContract = _primary;
        primaryDeployed = Primary(primaryContract);
    }

    function removeEntity(address _address) external onlyOwner{
        delete EntitiesList[_address];
    }

    function voteForContract(string calldata _initiativeName) external isEntity{
        primaryDeployed.requestInitiativeContract(_initiativeName, msg.sender);
        //can make this Delegate call
    }

    function addNewEntity(string calldata _name, string calldata _eType) external onlyOwner {
        EntitiesList[msg.sender] = EData({name: _name, eType: _eType, blocked: false, served: 0});
    }

    function blockEntity(address _eAddress) external onlyOwner{
        EntitiesList[_eAddress].blocked = true;
    }
}