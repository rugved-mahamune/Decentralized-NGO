pragma solidity >= 0.5.0;
pragma experimental ABIEncoderV2;

import "./NGO.sol";
import "./Entity.sol";

contract Primary {

    struct EVotes {
        address eAddress;
        uint voteCount;
    }
    struct Initiative {
        string name;
        address initiator;
        string description;
        uint amount;
        uint target;
        EVotes[] votes;
        string eType;
        bool active;
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }

    modifier onlyOnce {
        require(
            NGOAddress == address(0x0),
            "The NGO contract is already set!"
        );
        _;
    }
    address owner;
    address NGOAddress;
    address EntityAddress;
    NGO ngoDeployed;
    Entity entityDeployed;
    string[] initiativeNames;
    mapping (string => Initiative) public InitiativesList;
    
    constructor() public
    {
        owner = msg.sender;
    }

    function setNGOContract(address _ngoContract) external onlyOnce {
        NGOAddress = _ngoContract;
        ngoDeployed = NGO(NGOAddress);
    }

    function setEntityContract(address _entityContract) external onlyOnce {
        EntityAddress = _entityContract;
        entityDeployed = Entity(EntityAddress);
    }

    function startInitiative(string calldata _name, address _address, string calldata _desc, uint _target, string calldata _eType, bool  _active) external {
        require(
            InitiativesList[_name].active && msg.sender == NGOAddress,
            "The Initiative already is running."
        );
        Initiative storage initiativeObj;
        initiativeObj.name = _name;
        initiativeObj.description = _desc;
        initiativeObj.target = _target;
        initiativeObj.amount = 0;
        initiativeObj.eType = _eType;
        initiativeObj.active = _active;
        initiativeObj.initiator = _address;
        InitiativesList[_name] = initiativeObj;
        initiativeNames.push(_name);
    }

    function getOldInitiatives() public view returns (string[] memory) {
        string[] memory content = new string[](initiativeNames.length);
        uint j = 0;
        for (uint i = 0; i < initiativeNames.length; i++) {
            string memory temp = initiativeNames[i];
            if(!InitiativesList[temp].active){
                Initiative memory initiativeObj = InitiativesList[temp];
            content[j] = string(abi.encodePacked(initiativeObj.name, initiativeObj.description, initiativeObj.initiator, initiativeObj.target, initiativeObj.amount));
            j += 1;
            }
        }
        return content;
    }

    function getActiveInitiatives() public view returns (string[] memory) {
        string[] memory content = new string[](initiativeNames.length);
        uint j = 0;
        for (uint i = 0; i < initiativeNames.length; i++) {
            string memory temp = initiativeNames[i];
            if(InitiativesList[temp].active){
                Initiative memory initiativeObj = InitiativesList[temp];
            content[j] = string(abi.encodePacked(initiativeObj.name, initiativeObj.description, initiativeObj.initiator, initiativeObj.target, initiativeObj.amount));
            j += 1;
            }
        }
        return content;
    }

    function contribute(string memory _name, address _eAddress) public payable {
        InitiativesList[_name].amount += msg.value;
        setEntityVotes(_eAddress, _name, InitiativesList[_name].amount);
        if(InitiativesList[_name].amount >= InitiativesList[_name].target){
            fundEntity(_name, InitiativesList[_name].amount);
        }
    }

    function requestInitiativeContract(string calldata _name, address ngoAddress) external {
        setEntityVotes(ngoAddress, _name, 0);
    }

    function blockNGOListing(address _ngoAddress) external onlyOwner {
        ngoDeployed.blockNGO(_ngoAddress);
    }

    function blockEntity(address _eAddress) external onlyOwner {
        entityDeployed.blockEntity(_eAddress);
    }

/*
    function getEntityVotes(address _eAddress, string memory _name) internal returns(uint) {
        for(uint i = 0; i < InitiativesList[_name].votes.length; i++) {
            if(InitiativesList[_name].votes[i].eAddress == _eAddress){
                return InitiativesList[_name].votes[i].voteCount;
            }
            return 0;
        }
    }
*/
    function setEntityVotes(address _eAddress, string memory _name, uint amount) private {
        uint i = 0;
        for(i; i < InitiativesList[_name].votes.length; i++) {
            if(InitiativesList[_name].votes[i].eAddress == _eAddress){
                InitiativesList[_name].votes[i].voteCount = amount;
                return;
            }
        }
        InitiativesList[_name].votes.push(EVotes({eAddress: _eAddress, voteCount: amount}));
    }

    function fundEntity(string memory _name, uint _amount) private {
        address efundaddr = getSelectedEntity(_name);
        address(uint160(efundaddr)).transfer(_amount);
    }

    function getSelectedEntity(string memory _name) private view returns(address){
        uint maxVotes = 0;
        address maxAddress = address(0x0);
        for(uint i = 0; i < InitiativesList[_name].votes.length; i++) {
            if(InitiativesList[_name].votes[i].voteCount > maxVotes)
            {
                maxVotes = InitiativesList[_name].votes[i].voteCount;
                maxAddress = InitiativesList[_name].votes[i].eAddress;
            }
        }
        return maxAddress;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

}