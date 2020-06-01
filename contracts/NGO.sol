pragma solidity >= 0.5.0;

import "./Primary.sol";

contract NGO {
    
    address owner;
    address primaryContract;
    Primary primaryDeployed;
    struct NgoData {
        string name;
        string domain;
        bool blocked;
        uint served;
    }
    mapping (address => NgoData) private NgosList;

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
    //TO:DO check if the right msg.sender comes from primary
    modifier isNGO {
        require(
            !NgosList[msg.sender].blocked,
            "Only Legitimate NGOs can request for contract"
        );
        _;
    }
    constructor(address _primary) public
    {
        owner = msg.sender;
        primaryContract = _primary;
        primaryDeployed = Primary(primaryContract);
    }

    function removeNGO(address _address) external onlyOwner{
        delete NgosList[_address];
    }

    function removeNGO() external {
        delete NgosList[msg.sender];
    }

    function addNewNGO(string calldata _name, string calldata _domain, address _eAddress) external {
        NgosList[_eAddress] = NgoData({name: _name, domain: _domain, blocked: false, served: 0});
    }

    function blockNGO(address _eAddress) external onlyOwner{
        NgosList[_eAddress].blocked = true;
    }
    
    function startInitiative(string calldata _name, string calldata _desc, uint _target, string calldata _eType, bool  _active) external isNGO {
        primaryDeployed.startInitiative(_name, msg.sender, _desc, _target, _eType, _active);
    }
}