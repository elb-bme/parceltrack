// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Sensor {
    string public sensorId;
    string public sensorType;
    mapping(string => bool) public slas;

    event SensorRegistered(string sensorId, string sensorType);
    event SLAViolation(string indexed sla, string sensorId);

    constructor(string memory _sensorId, string memory _sensorType, string[] memory _slas) {
        sensorId = _sensorId;
        sensorType = _sensorType;
        for(uint i = 0; i < _slas.length; i++) {
            slas[_slas[i]] = true;
        }
        emit SensorRegistered(sensorId, sensorType);
    }

    function logViolation(string memory _sla) public {
        require(slas[_sla], "Invalid SLA");
        emit SLAViolation(_sla, sensorId);
    }
}