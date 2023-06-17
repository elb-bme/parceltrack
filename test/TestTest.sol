pragma solidity >=0.4.22 <0.9.0;

import "truffle/Assert.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../contracts/Parcel.sol";
import "../contracts/Governance.sol";
import "../contracts/Sensor.sol";
import "truffle/console.sol";

contract TestTest {
    Parcel public parcelContract;
    Governance public governanceContract;
    Sensor public sensorContract;
    function testMyTest() public {
        Parcel parcel = new Parcel("Edua", "E");
        address pAddress = address(parcel);
        console.log(msg.sender);
        console.log(pAddress);
        //AssertString.equal("b", "a");
    }

    function testParcelRegisterParcel() public {
        // Deploy the contracts
        parcelContract = new Parcel("Parcel", "PCL");
        governanceContract = new Governance(address(parcelContract));
        sensorContract = new Sensor();

        console.log("Gov contract:");        
        console.log(address(governanceContract));
        console.log("Sensor contract:");        
        console.log(address(sensorContract));
        uint parcelId = parcelContract.registerParcel(address(governanceContract), address(sensorContract));
        console.log("Parcel ID:");        
        console.log(parcelId); 
        address initialOwner = parcelContract.ownerOf(1);
        console.log("initialOwner:");        
        console.log(initialOwner);
        parcelContract.transferOwnership(msg.sender);
        uint tokenId = governanceContract.registerParcel(initialOwner, address(sensorContract), 100, "SLA 100");
        console.log("Token ID:");        
        console.log(tokenId);       
    }

  
    
    function testRegisterParcel() public {
        // Deploy the contracts
        parcelContract = new Parcel("Parcel", "PCL");
        governanceContract = new Governance(address(parcelContract));
        sensorContract = new Sensor();
        // Transfer ownership of parcelContract to the test contract
        parcelContract.transferOwnership(address(this));
        // Register the parcel
        uint parcelId = parcelContract.registerParcel(address(governanceContract), address(sensorContract));
        // Assert that the parcelId is not zero
        Assert.notEqual(parcelId, 0, "Parcel registration failed");
        // Assert the ownership of the parcel
        address owner = parcelContract.ownerOf(parcelId);
        Assert.equal(owner, address(this), "Incorrect parcel ownership");
        // Register the parcel in the governance contract
        uint tokenId = governanceContract.registerParcel(owner, address(sensorContract), 100, "SLA 100");
        // Assert that the tokenId is not zero
        Assert.notEqual(tokenId, 0, "Parcel registration in governance failed");
    }
        function testRegisterParcel2() public {
        // Deploy the contracts
        parcelContract = new Parcel("Parcel", "PCL");
        governanceContract = new Governance(address(parcelContract));
        sensorContract = new Sensor();

        // Register the parcel
        uint parcelId = parcelContract.registerParcel(address(governanceContract), address(sensorContract));

        // Assert that the parcelId is not zero
        Assert.notEqual(parcelId, 0, "Parcel registration failed");

        // Assert the ownership of the parcel
        address owner = parcelContract.ownerOf(parcelId);
        Assert.equal(owner, address(this), "Incorrect parcel ownership");

        // Register the parcel in the governance contract
        uint tokenId = governanceContract.registerParcel(owner, address(sensorContract), 100, "SLA 100");

        // Assert that the tokenId is not zero
        Assert.notEqual(tokenId, 0, "Parcel registration in governance failed");
    }
}
