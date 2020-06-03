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
            "Only Legitimate NGOs can request for contract"
        );
        primaryDeployed.startInitiative(_name, msg.sender, _desc, _target, _eType, _active);
    }

    function getNGOList() public view returns(string[] memory){
        string[] memory content = new string[](ngoListArray.length);
        uint j = 0;
        for (uint i = 0; i < ngoListArray.length; i++) {
            address temp = ngoListArray[i];
            if(NgosList[temp].allowed){
                NgoData memory ngoObj = NgosList[temp];
                content[j] = string(abi.encodePacked(ngoObj.name, ngoObj.domain, primaryDeployed.addressToString(ngoObj.ngoAddress), primaryDeployed.uintToString(ngoObj.served)));

            j += 1;
            }
        }
        return content;
    }
}