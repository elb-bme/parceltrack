pragma solidity >=0.4.22 <0.9.0;

import "./Sensor.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Parcel is ERC721 {
    
    uint256 private _parcelIds = 0;
    
    Sensor private sensorContract;

    struct SLA {
        string description;
        uint256 threshold;
        bool violated;
    }

    struct ParcelData {
        address currentOwner;
        address destination;
        uint256 deliveryStatus; // 0: InTransit, 1: Delivered
    }

    mapping(uint256 => ParcelData) private parcels;
    mapping(uint256 => SLA) private slas;

    event ParcelRegistered(uint256 indexed parcelId, address indexed owner);
    event ParcelTransferred(address indexed from, address indexed to, uint256 indexed parcelId);
    event SensorRegistered(uint256 indexed parcelId, uint256 indexed sensorId, address indexed owner);
    event SensorActivated(uint256 indexed parcelId, uint256 indexed sensorId);
    event SensorDeactivated(uint256 indexed parcelId, uint256 indexed sensorId);
    event SLASet(uint indexed _parcelId, uint indexed threshold);
    event SLAViolation(uint256 indexed parcelId, uint value);

    constructor() ERC721("Parcel", "PCL") { _parcelIds++; }

    function setSensorContract(address _sensorContract) external {
        require(_sensorContract != address(0), "Invalid Parcel contract address");
        sensorContract = Sensor(_sensorContract);
    }

    function registerParcel(
        address _destination,
        string memory _slaDescription,
        uint256 _slaThreshold
    ) public returns (uint256) {
        uint256 parcelId =_parcelIds;

        ParcelData storage parcel = parcels[parcelId];
        parcel.currentOwner = msg.sender;
        parcel.destination = _destination;
        parcel.deliveryStatus = 0;

        SLA memory newSLA;
        newSLA.description = _slaDescription;
        newSLA.threshold = _slaThreshold;
        slas[parcelId] = newSLA;

        _mint(msg.sender, parcelId);
        _parcelIds++;

        emit ParcelRegistered(parcelId, msg.sender);

        return parcelId;
    }

    function attachSensor(uint256 _parcelId) public returns (uint256) {
        require(_exists(_parcelId), "Parcel does not exist");
        uint threshold = slas[_parcelId].threshold;
        uint256 sensorId = sensorContract.attachSensor(_parcelId, threshold);
        emit SensorRegistered(_parcelId, sensorId, msg.sender);

        return sensorId;
    }

    function activateSensor(uint256 _parcelId) public {
        require(_exists(_parcelId), "Parcel does not exist");
        require(!(sensorContract.getSensorStatus(_parcelId)), "Sensor is already activated");

        sensorContract.activateSensor(_parcelId);
        uint sensorId = sensorContract.getSensorId(_parcelId);
        emit SensorActivated(_parcelId, sensorId);
    }

    function deactivateSensor(uint256 _parcelId) public {
        require(_exists(_parcelId), "Parcel does not exist");
        require((sensorContract.getSensorStatus(_parcelId)), "Sensor is already deactivated");

        sensorContract.deactivateSensor(_parcelId);
        uint sensorId = sensorContract.getSensorId(_parcelId);

        emit SensorDeactivated(_parcelId, sensorId);
    }


    function logValue(uint _parcelId, uint value) external {
        if(value > slas[_parcelId].threshold) {
            slas[_parcelId].violated = true;
            emit SLAViolation(_parcelId, value);
        }
    }


    function setSLA(uint256 _parcelId, uint256 threshold, string calldata description) external {
        slas[_parcelId].threshold = threshold;
        slas[_parcelId].description = description;
        slas[_parcelId].violated = false;

        emit SLASet(_parcelId, threshold);
    }

    function getSLA(uint256 tokenId) external view returns (uint256, bool, string memory) {

        SLA memory sla = slas[tokenId];
        return (sla.threshold, sla.violated, sla.description);
    }

    function checkSLAViolation(uint256 tokenId) public view returns (bool) {
        return slas[tokenId].violated;
    }

    function approveTransfer(address _to, uint256 _parcelId) public {
        address owner = ownerOf(_parcelId);
        require(_isApprovedOrOwner(msg.sender, _parcelId), "You are not allowed to approve");

        _approve(_to, _parcelId);
        emit Approval(owner, _to, _parcelId);
    }

    function transferParcel(
        address _from,
        address _to,
        uint256 _parcelId
    ) public {
        require(_isApprovedOrOwner(msg.sender, _parcelId), "Transfer not approved");
        require(_isSLAViolationFree(_parcelId), "SLA violation detected");
        require(_exists(_parcelId), "Parcel does not exist");

        _transfer(_from, _to, _parcelId);
        emit ParcelTransferred(_from, _to, _parcelId);
    }

    function _isSLAViolationFree(uint256 _parcelId) public view returns (bool) {
        return !slas[_parcelId].violated;
    }

    function isSLAViolated(uint256 _parcelId) public view returns (bool) {
        return slas[_parcelId].violated;
    }

    function getParcelOwner(uint256 _parcelId) public view returns (address) {
        return ownerOf(_parcelId);
    }

    function getParcelDestination(uint256 _parcelId) public view returns (address) {
        return parcels[_parcelId].destination;
    }

    function getDeliveryStatus(uint256 _parcelId) public view returns (uint256) {
        return parcels[_parcelId].deliveryStatus;
    }

    function getSensorStatus(uint256 _parcelId) public view returns (bool) {
        return sensorContract.getSensorStatus(_parcelId);
    }

    function getLatestParcelId() public view returns (uint256) {
        return _parcelIds;
    }

}