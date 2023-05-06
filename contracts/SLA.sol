// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/**
 * @title SLA
 * @dev Smart contract representing a Service Level Agreement (SLA) between a sender and a recipient
 */
contract SLA {
    string public slaId;
    uint public threshold;

    mapping(address => bool) public approvedSensors;

    event SLARegistered(string slaId, uint threshold);
    event SensorApproved(string slaId, address sensor);
    event SensorRevoked(string slaId, address sensor);

  /**
     * @dev Constructs a new SLA contract with the specified ID and threshold value
     * @param _slaId The ID of the new SLA
     * @param _threshold The threshold value for the new SLA
     */
    constructor(string memory _slaId, uint _threshold) {
      slaId = _slaId;
      threshold = _threshold;
      emit SLARegistered(slaId, threshold);
    }

    /**
     * @dev Approve a sensor to monitor this SLA
     * @param sensor The address of the sensor to approve
     */
    function approveSensor(address sensor) external {
        approvedSensors[sensor] = true;
        emit SensorApproved(slaId, sensor);
    }

    /**
     * @dev Revoke approval of a sensor to monitor this SLA
     * @param sensor The address of the sensor to revoke
     */
    function revokeSensor(address sensor) external {
        approvedSensors[sensor] = false;
        emit SensorRevoked(slaId, sensor);
    }
}
