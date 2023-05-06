// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
    @title Parcel Smart Contract
    @dev This smart contract represents a parcel with ownership, and SLA (Service Level Agreement) monitoring functionality.
    The parcel is registered by an owner with attached SLAs and sensors.
    The owner can initiate a handover of the parcel to another address, and the receiver can acknowledge the handover.
    The owner can also log SLA violations and deregister the parcel.
    */
contract Parcel is ERC721{

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

struct Parcel {
    address owner; // Address of the current owner of the parcel
    uint256 parcelId; // Unique identifier for the parcel
    SLA[] slas; // Mapping of SLAs to their status (true/false) for the parcel
    address[] sensors;
    mapping(address => bool) sensorStatus; // Mapping of attached sensors to their status (true/false) for the parcel
    mapping(address => bool) activeSensors;
    mapping(string => bool) slaViolations; // Mapping to track SLA violations
    ParcelMetadata metadata;
}
    /**
     * @dev Constructor function to initialize the Parcel smart contract with the ERC721 metadata.
     */    mapping(uint256 => Parcel) _parcels;    
    
    constructor() ERC721("Parcel", "PCL") {}
    
    /**
     * @dev Event emitted when a parcel is registered.
     * @param owner The address of the owner of the parcel.
     * @param parcelId The unique identifier for the parcel.
     */
    event ParcelRegistered(address indexed owner, uint parcelId); // Event emitted when a parcel is registered
    
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

struct SLA {
    string description;
    bool violated;
}
struct ParcelMetadata {
        uint256 weight;
        uint256 value;
        string content;
    }
/**
    @dev Constructor function to initialize the Parcel smart contract with the initial owner and parcelId.
    @param _owner The address of the initial owner of the parcel
    @param _parcelId The unique identifier for the parcel
    */
    constructor(address _owner, uint _parcelId) {
        owner = _owner;
        parcelId = _parcelId;
        emit ParcelRegistered(owner, parcelId);
    }

/**
 * @dev Registers a new parcel with the given properties.
 * @param _owner The address of the owner of the parcel.
 * @param weight The weight of the parcel in grams.
 * @param value The value of the parcel in Wei.
 * @param content A description of the contents of the parcel.
 * @param _sensors An array of sensor addresses to be associated with the parcel.
 * @param _slas An array of SLA addresses to be associated with the parcel.
 * @return The ID of the newly registered parcel.
 */
function registerParcel(
    address _owner,
    uint256 weight,
    uint256 value,
    string memory content,
    address[] memory _sensors,
    address[] memory _slas
) external returns (uint256) {
    require(_owner != address(0), "Invalid parcel owner");
    require(owner == address(0), "Parcel already registered");

    // Register the parcel with the given properties
    _tokenIds.increment();
    uint256 newParcelId = _tokenIds.current();
    _parcels[newParcelId] = Parcel({
        id: newParcelId,
        owner: _owner,
        sensors: _sensors,
        slas: new SLA[](_slas.length),
        sensorStatus: new mapping(address => bool)(),
        metadata: ParcelMetadata({
            weight: weight,
            value: value,
            content: content
        })
    });
    
    // Associate the parcel with the given SLAs
    for(uint i = 0; i < _slas.length; i++) {
        _parcels[newParcelId].slas[i] = SLA(_slas[i]);
    }
    
    // Mint the parcel to the first owner
    _mint(_owner, newParcelId);
    
    emit ParcelRegistered(_owner, newParcelId);
    return newParcelId;
}

    function getParcel(uint256 parcelId) external view returns (Parcel memory) {
        return _parcels[parcelId];
    }
/**
    @dev Function to initiate a handover of the parcel from the current owner to a new receiver.
    @param _sender The address of the current owner of the parcel
    @param _receiver The address of the new receiver of the parcel
    */
    function handoverFrom(address _sender, address _receiver) public {
        require(owner == _sender, "Only current owner can initiate handover");
        owner = _receiver;
        emit HandoverAttempted(_sender, _receiver, parcelId);(_sender, _receiver, parcelId);
    }

    /**
    @dev Function to confirm a handover of the parcel from the current owner to a new receiver.
    @param _sender The address of the current owner of the parcel
    @param _receiver The address of the new receiver of the parcel
    */
    function handoverTo(address _sender, address _receiver) public {
        require(owner == _sender, "Only current owner can acknowledge handover");
        emit HandoverAcknowledged(_sender, _receiver, parcelId);
    }

/**
 * @dev Logs an SLA violation for a parcel
 * @param _sla The SLA identifier
 */

function logViolation(string memory _sla) public {
    require(slas[_sla], "Invalid SLA"); // Ensure the SLA is valid
    slaViolations[_sla] = true; // Record the SLA violation
    emit SLAViolation(_sla, parcelId); // Emit the event
}

/**
 * @dev Deregisters a parcel
 */

function deregisterParcel() public {
    require(owner == msg.sender, "Only owner can deregister parcel"); // Ensure the caller is the owner
    owner = address(0); // Remove the owner
    _burn(parcelId); // Burn the NFT
    emit ParcelDeregistered(parcelId); // Emit the event
}

    function deregisterParcel() public {
        require(owner == msg.sender, "Only owner can deregister parcel");
        owner = address(0);
        parcelId = "";
        emit ParcelDeregistered(parcelId);
    }

/**
 * @dev Checks if an SLA violation occurred
 * @param _sla The SLA identifier
 * @return A boolean indicating if an SLA violation occurred
 */
function checkSLAViolation(string memory _sla) public view returns(bool) {
    return slaViolations[_sla]; // Return if an SLA violation occurred
}

 /**
 * @dev Adds an approved address for a parcel NFT
 * @param tokenId The ID of the parcel NFT
 * @param approved The address to add as an approved address
 */
function addApprovedAddress(uint256 tokenId, address approved) public {
    require(_isApprovedOrOwner(msg.sender, tokenId), "ParcelNFT: caller is not owner nor approved"); // Ensure the caller is the owner or approved
    _approve(approved, tokenId); // Add the approved address
}

    /**
 * @dev Retrieves the metadata of a parcel.
 * @param parcelId The ID of the parcel to retrieve metadata for.
 * @return The ParcelMetadata struct for the specified parcel.
 */
function getParcelMetadata(uint256 parcelId) external view returns (ParcelMetadata memory) {
    return _parcels[parcelId].metadata;
}

/**
 * @dev Retrieves the list of SLAs associated with a parcel.
 * @param parcelId The ID of the parcel to retrieve SLAs for.
 * @return The array of SLA structs associated with the specified parcel.
 */
function getSLAs(uint256 parcelId) external view returns (SLA[] memory) {
    return _parcels[parcelId].slas;
}

/**
 * @dev Retrieves the status of a sensor for a specific parcel.
 * @param parcelId The ID of the parcel to retrieve sensor status for.
 * @param sensor The address of the sensor to retrieve status for.
 * @return The status of the specified sensor for the specified parcel.
 */
function getSensorStatus(uint256 parcelId, address sensor) external view returns (bool) {
    return _parcels[parcelId].activeSensors[sensor];
}

/**
 * @dev Sets the status of a sensor for a specific parcel.
 * @param parcelId The ID of the parcel to set sensor status for.
 * @param sensor The address of the sensor to set status for.
 * @param status The new status for the specified sensor.
 */
function setSensorStatus(uint256 parcelId, address sensor, bool status) external {
    require(_isApprovedOrOwner(_msgSender(), parcelId), "Parcel: setSensorStatus caller is not owner nor approved");
    _parcels[parcelId].activeSensors[sensor] = status;
}

/**
 * @dev Attach sensors to the specified parcel.
 * @param _parcelId The ID of the parcel.
 * @param _sensors An array of sensor addresses to be attached to the parcel.
 * @notice Only the owner of the parcel can attach sensors to it.
 */
function attachSensors(uint256 _parcelId, address[] memory _sensors) public onlyOwner(_parcelId) {
    Parcel storage parcel = _parcels[_parcelId];
    for(uint i = 0; i < _sensors.length; i++){
        parcel.sensorAddresses.push(_sensors[i]);
        parcel.sensorStatus[_sensors[i]] = true;
        parcel.activeSensors[_sensors[i]] = true;
        emit SensorAttached(_parcelId, _sensors[i]);
    }
}

/**
 * @dev Attach SLAs to the specified parcel.
 * @param _parcelId The ID of the parcel.
 * @param _slas An array of SLA addresses to be attached to the parcel.
 * @notice Only the owner of the parcel can attach SLAs to it.
 */
function attachSLAs(uint256 _parcelId, address[] memory _slas) public onlyOwner(_parcelId) {
    Parcel storage parcel = _parcels[_parcelId];
    for(uint i = 0; i < _slas.length; i++){
        parcel.slaAddresses.push(_slas[i]);
        parcel.slaViolations[SLA(_slas[i]).description()] = false;
        emit SLAAttached(_parcelId, _slas[i]);
    }
}

/**
 * @dev Log a violation of the specified SLA for the parcel.
 * @param _parcelId The ID of the parcel.
 * @param _slaDescription The description of the violated SLA.
 * @notice Only a sensor attached to the parcel can log a violation of an SLA.
 */
function logSLAViolation(uint256 _parcelId, string memory _slaDescription) public onlySensor(_parcelId, msg.sender) {
    Parcel storage parcel = _parcels[_parcelId];
    parcel.slaViolations[_slaDescription] = true;
    emit SLAViolation(_parcelId, _slaDescription);
}


}