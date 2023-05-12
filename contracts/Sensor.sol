// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Sensor
 * @dev A smart contract for registering and managing sensors for tracking parcels
 */

contract Sensor is Ownable {
    string public sensorId;
    string public sensorType;
    mapping(string => bool) public slas;
    mapping(string => bool) public attachedParcels;

    event SensorRegistered(string sensorId, string sensorType);
    event SLAViolation(string indexed sla, string parcelId, string sensorId);
    event SensorAttached(string parcelId, string sensorId);
    event SensorDetached(string parcelId, string sensorId);

    constructor(string memory _sensorId, string memory _sensorType, string[] memory _slas) {
        sensorId = _sensorId;
        sensorType = _sensorType;
        for(uint i = 0; i < _slas.length; i++) {
            slas[_slas[i]] = true;
        }
        emit SensorRegistered(sensorId, sensorType);
    }

/**
 * @dev Attach the sensor to a parcel
 * @param _parcelId The ID of the parcel to attach the sensor to
 */
    function attachToParcel(string memory _parcelId) public onlyOwner {
        attachedParcels[_parcelId] = true;
        emit SensorAttached(_parcelId, sensorId);
    }

/**
 * @dev Detach the sensor from a parcel
 * @param _parcelId The ID of the parcel to detach the sensor from
 */
    function detachFromParcel(string memory _parcelId) public onlyOwner {
        attachedParcels[_parcelId] = false;
        emit SensorDetached(_parcelId, sensorId);
    }

/**
 * @dev Logs a violation of an SLA by the sensor attached to the parcel.
 *      The function stores the parcel ID that the sensor is attached to,
 *      so that when a violation occurs, it can be logged in the context of the parcel.
 * @param _sla The SLA that has been violated.
 * @param _parcelId The ID of the parcel that the sensor is attached to.
 */
    function logViolation(string memory _sla, string memory _parcelId) public {
        emit SLAViolation(_sla, _parcelId, sensorId);
    }
}
