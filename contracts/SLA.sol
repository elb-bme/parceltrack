// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SLA {
    string public slaId;
    uint public threshold;

    event SLARegistered(string slaId, uint threshold);

    constructor(string memory _slaId, uint _threshold) {
      slaId = _slaId;
      threshold = _threshold;
    }
}

