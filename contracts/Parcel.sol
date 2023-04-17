// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/**
    @title Parcel Smart Contract
    @dev This smart contract represents a parcel with ownership, condition, and SLA (Service Level Agreement) monitoring functionality.
    The parcel is registered by an owner with an initial condition and attached SLAs and sensors.
    The owner can initiate a handover of the parcel to another address, and the receiver can acknowledge the handover.
    The owner can also log SLA violations and deregister the parcel.
    */
contract Parcel {
    address public owner; // Address of the current owner of the parcel
    string public parcelId; // Unique identifier for the parcel
    string public condition; // Current condition of the parcel
    mapping(string => bool) public slas;  // Mapping of SLAs to their status (true/false) for the parcel
    mapping(address => bool) public attachedSensors; // Mapping of attached sensors to their status (true/false) for the parcel

    event ParcelRegistered(address indexed owner, string parcelId); // Event emitted when a parcel is registered
    event HandoverFrom(address indexed sender, address indexed receiver, string parcelId); // Event emitted when a handover is initiated by the owner
    event HandoverTo(address indexed sender, address indexed receiver, string parcelId); // Event emitted when a handover is acknowledged by the receiver
    event SLAViolation(string indexed sla, string parcelId); // Event emitted when a SLA violation is logged
    event ParcelDeregistered(string parcelId); // Event emitted when a parcel is deregistered

/**
    @dev Constructor function to initialize the Parcel smart contract with the initial owner and parcelId.
    @param _owner The address of the initial owner of the parcel
    @param _parcelId The unique identifier for the parcel
    */
    constructor(address _owner, string memory _parcelId) {
        owner = _owner;
        parcelId = _parcelId;
        condition = "New";
        emit ParcelRegistered(owner, parcelId);
    }

/**
    @dev Function to register a new parcel with the given owner, parcelId, condition, SLAs, and attached sensors.
    @param _owner The address of the owner of the parcel
    @param _parcelId The unique identifier for the parcel
    @param _condition The initial condition of the parcel
    @param _slas The array of SLAs to be attached to the parcel
    @param _sensors The array of sensors to be attached to the parcel
    */
    function registerParcel(address _owner, string memory _parcelId, string memory _condition, string[] memory _slas, address[] memory _sensors) public {
        require(owner == address(0), "Parcel already registered");
        owner = _owner;
        parcelId = _parcelId;
        condition = _condition;
        for(uint i = 0; i < _slas.length; i++) {
            slas[_slas[i]] = true;
        }
        for(uint i = 0; i < _sensors.length; i++) {
            attachedSensors[_sensors[i]] = true;
        }
        emit ParcelRegistered(owner, parcelId);
    }

/**
    @dev Function to initiate a handover of the parcel from the current owner to a new receiver.
    @param _sender The address of the current owner of the parcel
    @param _receiver The address of the new receiver of the parcel
    */
    function handoverFrom(address _sender, address _receiver) public {
        require(owner == _sender, "Only current owner can initiate handover");
        owner = _receiver;
        emit HandoverFrom(_sender, _receiver, parcelId);
    }

/**
    @dev Function to confirm a handover of the parcel from the current owner to a new receiver.
    @param _sender The address of the current owner of the parcel
    @param _receiver The address of the new receiver of the parcel
    */
    function handoverTo(address _sender, address _receiver) public {
        require(owner == _sender, "Only current owner can acknowledge handover");
        require(attachedSensors[_receiver], "Only attached sensors can acknowledge handover");
        emit HandoverTo(_sender, _receiver, parcelId);
    }

    function logViolation(string memory _sla) public {
        require(slas[_sla], "Invalid SLA");
        emit SLAViolation(_sla, parcelId);
    }

    function deregisterParcel() public {
        require(owner == msg.sender, "Only owner can deregister parcel");
        owner = address(0);
        parcelId = "";
        condition = "";
        emit ParcelDeregistered(parcelId);
    }
}