pragma solidity >= 0.5.0;
pragma experimental ABIEncoderV2;
import "./Primary.sol";

contract NGO {
    
    address owner;
    address primaryContract;
    Primary primaryDeployed;
    struct NgoData {
        string name;
        address ngoAddress;
        string domain;
        bool allowed;
        uint served;
    }
    address[] ngoListArray;
    mapping (address => NgoData) public NgosList;

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
    constructor(address _primary) public
    {
        owner = msg.sender;
        primaryContract = _primary;
        primaryDeployed = Primary(primaryContract);
    }

    function removeNGO() external {
        delete NgosList[msg.sender];
    }

    function addNewNGO(string calldata _name, string calldata _domain) external {
        NgosList[msg.sender] = NgoData({name: _name, domain: _domain, allowed: true, served: 0, ngoAddress: msg.sender});
        ngoListArray.push(msg.sender);
    }

    function blockNGO(address _eAddress) external onlyOwner{
        NgosList[_eAddress].allowed = false;
    }
    
    function startInitiative(string calldata _name, string calldata _desc, uint _target, string calldata _eType, bool  _active) external {
        require(
            NgosList[msg.sender].allowed,
            "Only Registered NGOs can request for contract"
        );
        primaryDeployed.startInitiative(_name, msg.sender, _desc, _target, _eType, _active);
    }

    function getNGOsCount() external view returns(address[] memory){
        return ngoListArray;
    }

    function getNGOList(address ngoAddress) public view returns(string memory,string memory, address, uint){
        NgoData memory ngoObj = NgosList[ngoAddress];
        return(ngoObj.name, ngoObj.domain, ngoObj.ngoAddress, ngoObj.served);
    }

    function getNGOName(address ngoAddress) public view returns(string memory) {
        return NgosList[ngoAddress].name;
    }

    function getNGODomain(address ngoAddress) public view returns(string memory) {
        return NgosList[ngoAddress].domain;
    }

    function getNGOServed(address ngoAddress) public view returns(uint) {
        return NgosList[ngoAddress].served;
    }
}