// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Parcel.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract Sensor {

    using Counters for Counters.Counter;
    Parcel private parcelContract;
    Counters.Counter private _sensorIds;

    struct SmartSensor {
        uint parcelId;
        bool active;
        uint threshold;
        bool violation;
    }

    mapping(uint256 => SmartSensor) private _sensorsById;
    mapping(uint256 => SmartSensor) private _sensorsByPId;
    mapping(uint256 => uint256) private _sensorToPId;
    mapping(uint256 => uint256) private _pIdToSensor;


    // Event to indicate a measured value has been logged
    event ValueLogged(uint sensorId, uint256 value);

    // Function to set the address of the associated Parcel contract
    function setParcelContract(address _parcelContract) external {
        require(_parcelContract != address(0), "Invalid Parcel contract address");
        parcelContract = Parcel(_parcelContract);
    }

    function attachSensor(uint parcelId, uint threshold) external returns(uint) {
        uint sensorId = _sensorIds.current();
        _sensorIds.increment();
        SmartSensor storage sensor = _sensorsById[sensorId];

        sensor.parcelId = parcelId;
        sensor.threshold = threshold;
        sensor.violation = false;
        sensor.active = false;

        _sensorsByPId[parcelId] = sensor;
        _sensorToPId[sensorId] = parcelId;
        _pIdToSensor[parcelId] = sensorId;

        return sensorId;
    }

    function activateSensor(uint256 _parcelId) external {
        _sensorsByPId[_parcelId].active = true;
    }

    function deactivateSensor(uint256 _parcelId) external {
        _sensorsByPId[_parcelId].active = false;
    }
    // Function to log a measured value for a specific sensor
    function logValue(uint sensorId, uint256 value) external {
        require(address(parcelContract) != address(0), "Parcel contract address not set");
        uint parcelId = _sensorToPId[sensorId];
        parcelContract.logValue(parcelId, value);
        emit ValueLogged(sensorId, value);
    }

    function getSensorStatus(uint256 _parcelId) public view returns (bool) {
        return _sensorsByPId[_parcelId].active;
    }

    function getSensorId(uint256 _parcelId) public view returns (uint256) {
        return _pIdToSensor[_parcelId];
    }

    function getSensorThreshold(uint256 _parcelId) public view returns (uint) {
        return _sensorsByPId[_parcelId].threshold;
    }

    function getSensorViolation(uint256 _parcelId) public view returns (bool) {
        return _sensorsByPId[_parcelId].violation;
    }

}
