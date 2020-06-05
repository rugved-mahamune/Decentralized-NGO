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
        bool allowed;
    }
    mapping (address => EData) private EntitiesList;

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
    address[] entityAddresses;
    constructor(address _primary) public
    {
        owner = msg.sender;
        primaryContract = _primary;
        primaryDeployed = Primary(primaryContract);
    }

    function removeEntity(address _address) external onlyOwner{
        delete EntitiesList[_address];
    }

    function voteForContract(string calldata _initiativeName) external{
        require(
            EntitiesList[msg.sender].allowed,
            "Only Legitimate Entities can request for contract"
        );
        primaryDeployed.requestInitiativeContract(_initiativeName, msg.sender);
        //can make this Delegate call
    }

    function addNewEntity(string calldata _name, string calldata _eType) external {
        require(
            !EntitiesList[msg.sender].allowed,
            "Entity is already created"
        );
        EntitiesList[msg.sender] = EData({name: _name, eType: _eType, allowed: true, served: 0});
        entityAddresses.push(msg.sender);
    }

    function blockEntity(address _eAddress) external onlyOwner{
        EntitiesList[_eAddress].allowed = false;
    }

    function getEntitiesList() public view returns(address[] memory){
        return entityAddresses;
    }

    function getEntitiyName(address _entityAddress) public view returns(string memory){
        return EntitiesList[_entityAddress].name;
    }

    function getEntitiyType(address _entityAddress) public view returns(string memory){
        return EntitiesList[_entityAddress].eType;
    }

    function getEntitiyServed(address _entityAddress) public view returns(uint){
        return EntitiesList[_entityAddress].served;
    }

    function getEntitiyBlocked(address _entityAddress) public view returns(bool){
        return !EntitiesList[_entityAddress].allowed;
    }
}