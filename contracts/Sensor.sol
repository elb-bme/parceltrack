// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Parcel.sol";

contract Sensor is Ownable {
    Parcel private parcelContract;

    // Event to indicate a measured value has been logged
    event ValueLogged(address indexed sensor, uint256 value);

    // Function to set the address of the associated Parcel contract
    function setParcelContract(address _parcelContract) external onlyOwner {
        require(_parcelContract != address(0), "Invalid Parcel contract address");
        parcelContract = Parcel(_parcelContract);
    }

    // Function to log a measured value for a specific sensor
    function logValue(uint256 value) external {
        require(address(parcelContract) != address(0), "Parcel contract address not set");
        require(value > 0, "Invalid measured value");

        address sensorAddress = address(this);
        uint256 tokenId = parcelContract.getSensorTokenId(sensorAddress);

        require(tokenId > 0, "Sensor not associated with any parcel");

        // Log the measured value
        emit ValueLogged(sensorAddress, value);

        // Perform any other operations with the measured value as needed
    }
}
