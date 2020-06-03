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
        mapping (address => uint) votes;
        string eType;
        address[] entities;
        bool active;
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
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

    function setNGOContract(address _ngoContract) external {
        require(
            NGOAddress == address(0x0),
            "The NGO contract is already set!"
        );
        NGOAddress = _ngoContract;
        ngoDeployed = NGO(NGOAddress);
    }

    function setEntityContract(address _entityContract) external {
        require(
            EntityAddress == address(0x0),
            "The Entity contract is already set!"
        );
        EntityAddress = _entityContract;
        entityDeployed = Entity(EntityAddress);
    }

    function startInitiative(string calldata _name, address _address, string calldata _desc, uint _target, string calldata _eType, bool  _active) external {
        require(
            !InitiativesList[_name].active && msg.sender == NGOAddress,
            "The Initiative already is running."
        );
/*        Initiative  initiativeObj = Initiative({name: _name, description: _desc, target: _target, amount: 0, eType: _eType, active: _active, initiator: _address,votes: EVotes[]});
        initiativeObj.name = _name;
        initiativeObj.description = _desc;
        initiativeObj.target = _target;
        initiativeObj.amount = 0;
        initiativeObj.eType = _eType;
        initiativeObj.active = _active;
        initiativeObj.initiator = _address;*/ 
        InitiativesList[_name] = Initiative({name: _name, description: _desc, target: _target, amount: 0, eType: _eType, active: _active, initiator: _address, entities: new address[](0)});

        initiativeNames.push(_name);
    }

    function getOldInitiatives() public view returns (string[] memory) {
        string[] memory content = new string[](initiativeNames.length);
        uint j = 0;
        for (uint i = 0; i < initiativeNames.length; i++) {
            string memory temp = initiativeNames[i];
            if(!InitiativesList[temp].active){
                Initiative memory initiativeObj = InitiativesList[temp];
            content[j] = string(abi.encodePacked(initiativeObj.name, ":", initiativeObj.description,":", addressToString(initiativeObj.initiator),":", uintToString(initiativeObj.target),":", uintToString(initiativeObj.amount)));
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
            content[j] = string(abi.encodePacked(initiativeObj.name, initiativeObj.description, addressToString(initiativeObj.initiator),  uintToString(initiativeObj.target), uintToString(initiativeObj.amount)));
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
        for(i; i < InitiativesList[_name].entities.length; i++) {
            address currAddress = InitiativesList[_name].entities[i];
            if(currAddress == _eAddress){
                InitiativesList[_name].votes[currAddress] = amount;
                return;
            }
        }
        InitiativesList[_name].entities.push(_eAddress);
        InitiativesList[_name].votes[_eAddress] = amount;
    }

    function fundEntity(string memory _name, uint _amount) private {
        address efundaddr = getSelectedEntity(_name);
        address(uint160(efundaddr)).transfer(_amount);
    }

    function getSelectedEntity(string memory _name) public view returns(address){
        uint maxVotes = 0;
        uint i = 0;
        address maxAddress = address(0x0);
        for(i; i < InitiativesList[_name].entities.length;) {
            if(i>=InitiativesList[_name].entities.length) return maxAddress;
            address currAddress = InitiativesList[_name].entities[i];
            if(InitiativesList[_name].votes[currAddress] > maxVotes){
                maxVotes = InitiativesList[_name].votes[currAddress];
                maxAddress = currAddress;
            }
            i = i+1;
        }
    return maxAddress;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function addressToString(address _addr) public pure returns(string memory) 
    {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(51);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function uintToString(uint _num) public pure returns (string memory) {
        string memory op;
        uint rem;
        while(_num > 9)
        {
            rem = _num % 10;
            _num = _num/10;
            op = string(abi.encodePacked(op,rem));
        }
        op = string(abi.encodePacked(op,_num));
        return op;
    }
}