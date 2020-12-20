// SPDX-License-Identifier: MIT
pragma solidity >0.5.0;

// import './ERC721.sol';

// /// @notice The Ecommerce Token that implements the ERC721 token with mint function
// /// @author Merunas Grincalaitis <merunasgrincalaitis@gmail.com>
// contract EcommerceToken is ERC721 {
//     address public ecommerce;
//     bool public isEcommerceSet = false;
//     /// @notice To generate a new token for the specified address
//     /// @param _to The receiver of this new token
//     /// @param _tokenId The new token id, must be unique
//     function mint(address _to, uint256 _tokenId) public {
//         require(msg.sender == ecommerce, 'Only the ecommerce contract can mint new tokens');
//         _mint(_to, _tokenId);
//     }

//     /// @notice To set the ecommerce smart contract address
//     function setEcommerce(address _ecommerce) public {
//         require(!isEcommerceSet, 'The ecommerce address can only be set once');
//         require(_ecommerce != address(0), 'The ecommerce address cannot be empty');
//         isEcommerceSet = true;
//         ecommerce = _ecommerce;
//     }
// }

contract EducationParticipantMsg{
    uint32 public dutyId_id = 0;
    uint32 public participant_id = 0;
    uint32 public owner_id = 0;
   
   //学生各种身份认证的参与者（包括身份授权人和身份认证者）
   struct participant{
        string userName;
        string password;
        string participantType;
        address participantAddress;
    }
    mapping (uint32 => participant) public participants;
    
    
    //学生身份的职责和权力
     struct duty{
        string position;
        string work;
        string power;
        address dutyOwner;
        uint32 mfgTimeStamp;
     }
     mapping(uint32 => duty) public duties;
    
    //身份职责的所属人
    struct ownership{
        uint32 dutyId;
        uint32 ownerId;
        uint32 trxTimeStamp;
        address dutyOwner;
    }
    
    mapping(uint32 => ownership) public ownerships;
    mapping(uint32 => uint32[]) public dutyTrack;
    
    event TransferOwnership(uint32 dutyId);
    
    //添加身份认证的参与者
    function addParticipant(string memory _name,string memory _pass,address _pAdd, string memory _pType) public returns(uint32){
        uint32 userId = participant_id++;
        participants[userId].userName = _name;
        participants[userId].password = _pass;
        participants[userId].participantAddress = _pAdd;
        participants[userId].participantType = _pType;

        return userId;
    }
    
    function getParticipant(uint32 _participant_id) public view returns(string memory,address,string memory){
        return(participants[_participant_id].userName,participants[_participant_id].participantAddress,participants[_participant_id].participantType);
    }
    
    function addduty(uint32 _ownerId,
                        string memory _position,
                        string memory _work,
                        string memory _power
                        ) public returns(uint32){
        if(keccak256(abi.encodePacked(participants[_ownerId].participantType)) == keccak256("Authorized person")){
            uint32 dutyId = dutyId_id++;
            duties[dutyId].position = _position;
            duties[dutyId].work = _work;
            duties[dutyId].power = _power;
            duties[dutyId].dutyOwner = participants[_ownerId].participantAddress;
            duties[dutyId].mfgTimeStamp = uint32(block.timestamp);
            
            return dutyId;
        }
        return 0;
    }
    
    function getduty(uint32 _dutyId) public view returns(string memory,string memory,string memory,address,uint32){
        return (duties[_dutyId].position,
        duties[_dutyId].work,
        duties[_dutyId].power,
        duties[_dutyId].dutyOwner,
        duties[_dutyId].mfgTimeStamp
        );
    }
    
    modifier onlyOwner(uint32 _dutyId){
        require(msg.sender == duties[_dutyId].dutyOwner,"Not Owner");
        _;
    }
    
    function newOwner(uint32 _user1Id,uint32 _user2Id, uint32 _dutyId) public onlyOwner(_dutyId) returns(bool){
        participant memory p1 = participants[_user1Id];
        participant memory p2 = participants[_user2Id];
        uint32 ownership_id = owner_id++;
        
        if(keccak256(abi.encodePacked(p1.participantType))== keccak256("Authorized person")
        && keccak256(abi.encodePacked(p2.participantType)) == keccak256("Identity participant")){
            ownerships[ownership_id].dutyId = _dutyId;
            ownerships[ownership_id].dutyOwner = p2.participantAddress;
            ownerships[ownership_id].ownerId = _user2Id;
            ownerships[ownership_id].trxTimeStamp = uint32(block.timestamp);
            duties[_dutyId].dutyOwner = p2.participantAddress;
            dutyTrack[_dutyId].push(ownership_id);
            emit TransferOwnership(_dutyId);
            
            return(true);
        } 
    }
    
     function getProvenance(uint32 _dutyId) external view returns(uint32[] memory){
        return dutyTrack[_dutyId];
    }
    
    function getOwnership(uint32 _regId) public view returns (uint32,uint32,address,uint32){
        ownership memory r = ownerships[_regId];
        return(r.dutyId,r.ownerId,r.dutyOwner,r.trxTimeStamp);
    }
    
    function authenticateParticipant(uint32 _uid,
        string memory _uname,
        string memory _pass,
        string memory _utype
        ) public view returns(bool){
        if(
            keccak256(abi.encodePacked(participants[_uid].participantType)) == 
            keccak256(abi.encodePacked(_utype))
            ){
            if(
                keccak256(abi.encodePacked(participants[_uid].userName))==
                keccak256(abi.encodePacked(_uname))
                ){
                if(
                    keccak256(abi.encodePacked(participants[_uid].password))==
                    keccak256(abi.encodePacked(_pass))){
                    return(true);
                }
            }
        }
        return(false);
    }
}