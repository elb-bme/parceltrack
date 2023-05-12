// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
    @title Parcel Smart Contract
    @dev This smart contract represents a parcel with ownership, and SLA (Service Level Agreement) monitoring functionality.
    The parcel is registered by an owner with attached SLAs and sensors.
    The owner can initiate a handover of the parcel to another address, and the receiver can acknowledge the handover.
    The owner can also log SLA violations and deregister the parcel.
    */
contract ParcelManager is ERC721, Ownable {

/**
     * @dev Event emitted when a parcel is registered.
     * @param owner The address of the owner of the parcel.
     * @param parcelId The unique identifier for the parcel.
     */
    event ParcelRegistered(address indexed owner, uint parcelId); // Event emitted when a parcel is registered
    
    struct Parcel {
        uint256 parcelId;
        mapping(address => bool) sensorStatus;
        mapping(address => bool) activeSensors;
        mapping(uint256 => SLA[]) _parcelSLAs;    
        mapping(string => bool) slaViolations; // Mapping to track SLA violations
    }
    
    mapping(uint256 => Parcel) _parcels;

    struct SLA {
       string description;
       bool violated;
    }
    /**
     * @dev Constructor function to initialize the Parcel smart contract with the ERC721 metadata.
     */       
    constructor() ERC721("Parcel", "PCL") Ownable() {}    

    
    
    /**
     * @dev Event emitted when a handover is initiated by the owner.
     * @param sender The address of the current owner of the parcel.
     * @param receiver The address of the new receiver of the parcel.
     * @param parcelId The unique identifier for the parcel.
     */
     event HandoverAttempted(address indexed sender, address indexed receiver, uint parcelId); // Event emitted when a handover is initiated by the owner
    
    /**
     * @dev Event emitted when a handover is acknowledged by the receiver.
     * @param sender The address of the current owner of the parcel.
     * @param receiver The address of the new receiver of the parcel.
     * @param parcelId The unique identifier for the parcel.
     */
     event HandoverAcknowledged(address indexed sender, address indexed receiver, uint parcelId); // Event emitted when a handover is acknowledged by the receiver
    
    /**
     * @dev Event emitted when a SLA violation is logged.
     * @param sla The description of the violated SLA.
     * @param parcelId The unique identifier for the parcel.
     */
     event SLAViolation(string indexed sla, uint parcelId); // Event emitted when a SLA violation is logged
    
    /**
     * @dev Event emitted when a parcel is deregistered.
     * @param parcelId The unique identifier for the parcel.
     */
     event ParcelDeregistered(uint parcelId); // Event emitted when a parcel is deregistered

    /**
    * @dev Registers a new parcel with the given parcel ID and attached sensors.
    * @param _parcelId The unique identifier for the parcel.
    * @param _attachedSensors The array of addresses representing the attached sensors.
    */
function registerParcel(uint256 _parcelId, address[] memory _attachedSensors) external {
    require(!_exists(_parcelId), "Parcel ID already exists");

    // Mint a new token for the parcel
    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();
    _mint(msg.sender, newTokenId);

    // Create a new ParcelData struct
    ParcelData storage parcel = _parcels[newTokenId];

    // Update the parcel details
    parcel.parcelId = _parcelId;
    parcel.sensors = _attachedSensors;

    emit ParcelRegistered(msg.sender, _parcelId);
}


    function getParcel(uint256 _parcelId) external view returns (Parcel) {
        return _parcels[_parcelId];
    }
    /**
    @dev Function to initiate a handover of the parcel from the current owner to a new receiver.
    @param _sender The address of the current owner of the parcel
    @param _receiver The address of the new receiver of the parcel
    */
    function handoverFrom(address _sender, address _receiver) public {
        require(_parcels[_sender].owner == _sender, "Only current owner can initiate handover");
        _parcels[_sender].owner = _receiver;
        emit HandoverAttempted(_sender, _receiver, _parcels[_sender].parcelId);
    }

    /**
    @dev Function to confirm a handover of the parcel from the current owner to a new receiver.
    @param _sender The address of the current owner of the parcel
    @param _receiver The address of the new receiver of the parcel
    */
    function handoverTo(address _sender, address _receiver) public {
        require(_parcels[_sender].owner == _sender, "Only current owner can acknowledge handover");
        emit HandoverAcknowledged(_sender, _receiver, _parcels[_sender].parcelId);
    }

/**
 * @dev Deregisters a parcel
 */
function deregisterParcel() public {
        uint256 parcelId = _parcels[msg.sender].parcelId;
        delete _parcels[parcelId];
        _burn(parcelId);
        emit ParcelDeregistered(parcelId);
    }

function balanceOf(address _owner) public view virtual override returns (uint256) {
    require(_owner != address(0), "ERC721: balance query for the zero address");
    uint256 balance = 0;
    for (uint256 i = 1; i <= _tokenIds.current(); i++) {
        if (_exists(i) && _parcels[i].owner == _owner) {
            balance++;
        }
    }
    return balance;
}

function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: owner query for nonexistent token");
        return _parcels[tokenId].owner;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _transfer(from, to, tokenId);
    }
/**
 * @dev checkSLAViolation
 * @param _sla The SLA identifier
 * @return A boolean indicating if an SLA violation occurred
 */
function checkSLAViolation(uint256 _parcelId, string memory _sla) public view returns (bool) {
    ParcelData storage parcel = _parcels[_parcelId];
    return parcel.slaViolations[_sla];
}


/**
 * @dev Retrieves the list of SLAs associated with a parcel.
 * @param parcelId The ID of the parcel to retrieve SLAs for.
 * @return The array of SLA structs associated with the specified parcel.
 */
function getSLAs(uint256 _parcelId) public view returns (SLA[] memory) {
    ParcelData storage parcel = _parcels[_parcelId];
    return parcel._parcelSLAs[_parcelId];
}


/**
 * @dev Retrieves the status of a sensor for a specific parcel.
 * @param parcelId The ID of the parcel to retrieve sensor status for.
 * @param sensor The address of the sensor to retrieve status for.
 * @return The status of the specified sensor for the specified parcel.
 */
function getSensorStatus(uint256 _parcelId, address sensor) external view returns (bool) {
    return _parcels[_parcelId].activeSensors[sensor];
}

/**
 * @dev Sets the status of a sensor for a specific parcel.
 * @param parcelId The ID of the parcel to set sensor status for.
 * @param sensor The address of the sensor to set status for.
 * @param status The new status for the specified sensor.
 */
function setSensorStatus(uint256 _parcelId, address sensor, bool status) external {
    require(_isApprovedOrOwner(_msgSender(), _parcelId), "Parcel: setSensorStatus caller is not owner nor approved");
    _parcels[_parcelId].activeSensors[sensor] = status;
}

/**
 * @dev Attach sensors to the specified parcel.
 * @param _parcelId The ID of the parcel.
 * @param _sensors An array of sensor addresses to be attached to the parcel.
 * @notice Only the owner of the parcel can attach sensors to it.
 */
function attachSensors(uint256 _parcelId, address[] memory _sensors) public {
    Parcel parcel = _parcels[_parcelId];
    for(uint i = 0; i < _sensors.length; i++){
        parcel.sensorAddresses.push(_sensors[i]);
        parcel.sensorStatus[_sensors[i]] = true;
        parcel.activeSensors[_sensors[i]] = true;
}}

/**
 * @dev Attach SLAs to the specified parcel.
 * @param _parcelId The ID of the parcel.
 * @param _slas An array of SLA addresses to be attached to the parcel.
 * @notice Only the owner of the parcel can attach SLAs to it.
 */
function attachSLAs(uint256 _parcelId, address[] memory _slas) public {
    Parcel parcel = _parcels[_parcelId];
    for(uint i = 0; i < _slas.length; i++){
        parcel.slaAddresses.push(_slas[i]);
        parcel.slaViolations[SLA(_slas[i]).description()] = false;
    }
}

/**
 * @dev Log a violation of the specified SLA for the parcel.
 * @param _parcelId The ID of the parcel.
 * @param _slaDescription The description of the violated SLA.
 * @notice Only a sensor attached to the parcel can log a violation of an SLA.
 */
function logSLAViolation(uint256 _parcelId, string memory _slaDescription) public {
    Parcel parcel = _parcels[_parcelId];
    parcel.slaViolations[_slaDescription] = true;
    emit SLAViolation(_parcelId, _slaDescription);
}


}