// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "truffle/Assert.sol";
import "../contracts/Parcel.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

/**
 * @title TestParcelSLA
 * @dev This contract is used to test the SLA functionality of the Parcel contract.
 */
contract TestParcelSLA is ERC721Holder {
    Parcel parcel;
    address constant OWNER = 0x627306090abab3a6e1400e9345bc60c78a8bef57;
    address constant RECEIVER = 0xf17f52151ebef6c7334fad080c5704d77216b732;
    uint256 constant PARCEL_WEIGHT = 1000;
    uint256 constant PARCEL_VALUE = 1000000000000000000;
    string constant PARCEL_CONTENT = "A test parcel";
    string constant SLA_DESCRIPTION = "Delivery time less than 24 hours";
    uint256 parcelId;

    /**
     * @dev Runs before each test case to create a new Parcel contract instance and register a new parcel.
     */
    function beforeEach() public {
        parcel = new Parcel();
        parcelId = parcel.registerParcel(
            OWNER,
            PARCEL_WEIGHT,
            PARCEL_VALUE,
            PARCEL_CONTENT,
            new address[](0),
            new address[](1)
        );
    }

    /**
     * @dev Tests if an SLA is successfully attached to the parcel.
     */
    function testAttachSLA() public {
        parcel.addSLA(parcelId, SLA_DESCRIPTION);

        bool hasSLA = parcel.hasSLA(parcelId, SLA_DESCRIPTION);

        Assert.equal(hasSLA, true, "SLA not attached to parcel");
    }

    /**
     * @dev Tests if an SLA violation is successfully logged.
     */
    function testLogSLAViolation() public {
        parcel.addSLA(parcelId, SLA_DESCRIPTION);
        parcel.logSLAViolation(parcelId, SLA_DESCRIPTION);

        bool hasSLAViolation = parcel.hasSLAViolation(parcelId, SLA_DESCRIPTION);

        Assert.equal(hasSLAViolation, true, "SLA violation not logged");
    }

    /**
     * @dev Tests if the SLA violation is properly tracked.
     */
    function testTrackSLAViolation() public {
        parcel.addSLA(parcelId, SLA_DESCRIPTION);
        parcel.logSLAViolation(parcelId, SLA_DESCRIPTION);

        bool hasSLAViolation = parcel.hasSLAViolation(parcelId, SLA_DESCRIPTION);
        uint256[] memory slaViolations = parcel.getSLAViolations(parcelId, SLA_DESCRIPTION);

        Assert.equal(hasSLAViolation, true, "SLA violation not logged");
        Assert.equal(slaViolations.length, 1, "Wrong number of SLA violations tracked");
        Assert.equal(slaViolations[0], block.timestamp, "SLA violation timestamp not tracked correctly");
    }
}