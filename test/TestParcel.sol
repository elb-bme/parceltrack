// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "truffle/Assert.sol";
import "../contracts/Parcel.sol";
import "../contracts/Governance.sol";
import "../contracts/Sensor.sol";

contract SupplyChainTest {
    Parcel private parcelContract;
    Governance private governanceContract;
    Sensor private sensorContract;

    function beforeEach() public {
        parcelContract = new Parcel("Parcel", "PARCEL");
        sensorContract = new Sensor();
        governanceContract = new Governance(address(parcelContract));
        sensorContract.setParcelContract(address(parcelContract));
    }

    function testHandoverFunctionality() public {
        // Register a parcel
        parcelContract.registerParcel();

        // Get the initial owner of the parcel
        address initialOwner = parcelContract.ownerOf(1);

        // Initiate handover to another address
        parcelContract.initiateHandover(1, address(this));

        // Verify that the handover was initiated correctly
        Assert.equal(parcelContract.ownerOf(1), address(this), "Handover not initiated correctly");

        // Verify that the ownership of the parcel has changed
        Assert.notEqual(parcelContract.ownerOf(1), initialOwner, "Parcel ownership not changed");
    }

    function testSLAViolation() public {
        // Register a parcel
        parcelContract.registerParcel();

        // Set an SLA threshold for the parcel
        governanceContract.setSLA(1, 100, "SLA Threshold");

        // Log a sensor value that violates the SLA threshold
        sensorContract.logValue(200);

        // Verify that the SLA violation event is emitted
        (uint256 threshold, bool violated, string memory description) = governanceContract.getSLA(1);
        Assert.isTrue(violated, "SLA violation not detected");
    }

    function testSensorTokenIDRetrieval() public {
        // Register multiple parcels
        parcelContract.registerParcel();
        parcelContract.registerParcel();
        parcelContract.registerParcel();

        // Associate each parcel with a different sensor
        parcelContract.setSensorTokenId(address(sensorContract), 1);
        parcelContract.setSensorTokenId(address(sensorContract), 2);
        parcelContract.setSensorTokenId(address(sensorContract), 3);

        // Retrieve the sensor token ID for each sensor and verify
        Assert.equal(parcelContract.getSensorTokenId(address(sensorContract)), 1, "Incorrect sensor token ID");
        Assert.equal(parcelContract.getSensorTokenId(address(sensorContract)), 2, "Incorrect sensor token ID");
        Assert.equal(parcelContract.getSensorTokenId(address(sensorContract)), 3, "Incorrect sensor token ID");
    }

    function testTransferFunctionality() public {
        // Register a parcel
        parcelContract.registerParcel();

        // Transfer ownership to another address
        parcelContract.transferFrom(address(this), address(governanceContract), 1);

        // Verify that the ownership transfer was successful
        Assert.equal(parcelContract.ownerOf(1), address(governanceContract), "Ownership transfer failed");
    }
}