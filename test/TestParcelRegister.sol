// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "truffle/Assert.sol";
import "../contracts/Parcel.sol";

/**
 * @title TestParcelRegister
 * @dev Contract for testing the Parcel contract's parcel registration functionality.
 */
contract TestParcelRegister {
    Parcel parcel;

    /**
     * @dev Runs before each test function to create a new instance of the Parcel contract.
     */
    function beforeEach() public {
        parcel = new Parcel();
    }

    /**
     * @dev Tests the registerParcel function of the Parcel contract.
     * @dev Creates a new parcel and tests that its metadata, attached sensors, and attached SLAs match the input parameters.
     */
    function testRegisterParcel() public {
        // Set up input parameters for the parcel
        address owner = address(0x123);
        uint256 weight = 100;
        uint256 value = 500;
        string memory content = "test content";
        address[] memory sensors = new address[](2);
        sensors[0] = address(0x456);
        sensors[1] = address(0x789);
        address[] memory slas = new address[](1);
        slas[0] = address(0xABC);

        // Register the parcel and get its ID
        uint256 parcelId = parcel.registerParcel(owner, weight, value, content, sensors, slas);

        // Test that the parcel's metadata matches the input parameters
        Parcel.ParcelMetadata memory metadata = parcel.getParcelMetadata(parcelId);
        Assert.equal(metadata.weight, weight, "Parcel weight should match");
        Assert.equal(metadata.value, value, "Parcel value should match");
        Assert.equal(metadata.content, content, "Parcel content should match");

        // Test that the parcel's attached sensors match the input parameters
        address[] memory attachedSensors = parcel.getAttachedSensors(parcelId);
        Assert.equal(attachedSensors.length, sensors.length, "Number of attached sensors should match");
        Assert.equal(attachedSensors[0], sensors[0], "Attached sensor address should match");
        Assert.equal(attachedSensors[1], sensors[1], "Attached sensor address should match");

        // Test that the parcel's attached SLAs match the input parameters
        Parcel.SLA[] memory attachedSlas = parcel.getAttachedSlas(parcelId);
        Assert.equal(attachedSlas.length, slas.length, "Number of attached SLAs should match");
        Assert.equal(attachedSlas[0].description, "", "SLA description should be empty");
        Assert.equal(attachedSlas[0].violated, false, "SLA violation should be false");
    }
}
