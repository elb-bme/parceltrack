// Import the required libraries
const { expect } = require("chai");
const Web3 = require("web3");



// Import the compiled contract artifacts
const ParcelArtifact = require("../build/contracts/Parcel.json");
const SensorArtifact = require("../build/contracts/Sensor.json");

// Retrieve the deployed contract instances
const ParcelContract = artifacts.require("Parcel");
const SensorContract = artifacts.require("Sensor");

contract("Contract Deployment and Initialization", (accounts) => {
  let parcelContract;
  let sensorContract;

  before(async () => {
    web3 = new Web3("http://localhost:7545");

    // Deploy the contracts
    parcelContract = await ParcelContract.new();
    sensorContract = await SensorContract.new();
  });

  it("should deploy the ParcelContract", async () => {
    assert.ok(parcelContract.address, "ParcelContract deployment failed");
  });

  it("should deploy the SensorContract", async () => {
    assert.ok(sensorContract.address, "SensorContract deployment failed");
  });
  
  // Test Case 3: Activate a sensor and verify that the sensor status is updated correctly
    it("should activate a sensor and update the sensor status correctly", async () => {
    const parcelId = 1; // Replace with the desired parcel ID
  
    // Call the activateSensor function
    await sensorContract.activateSensor(parcelId);
  
    // Verify that the sensor status is set to true for the activated sensor by checking the _sensorsByPId mapping
    const sensorStatus = await sensorContract.getSensorStatus(parcelId);
    assert(sensorStatus === true, "Sensor status should be true after activation");
  });

    it("should transfer ownership or custody of a parcel and verify ownership changes", async () => {
    // Call the registerParcel function to create a new parcel with ownerAccount1
    const registerTx = await parcelContract.registerParcel("0x7eEE0DEebFd2AE57744d0f473A9baedAA0F775Fa", "SLA Description", 100);
    parcelId = 1;
  
    // Verify the initial ownership of the parcel
    const initialOwner = await parcelContract.ownerOf(parcelId);
    expect(initialOwner).to.equal("0x7eEE0DEebFd2AE57744d0f473A9baedAA0F775Fa");
  
    // Call the approveTransfer function to grant approval for transfer from ownerAccount1 to ownerAccount2
    await parcelContract.approveTransfer("0xc45A67dF151d783Ed4651380DF8154A7924618C1", parcelId);
  
    // Verify that the approval was successful
    const approvedAddress = await parcelContract.getApproved(parcelId);
    expect(approvedAddress).to.equal("0xc45A67dF151d783Ed4651380DF8154A7924618C1");
  
    // Call the transferParcel function to transfer ownership from ownerAccount1 to ownerAccount2
    await parcelContract.transferParcel("0x7eEE0DEebFd2AE57744d0f473A9baedAA0F775Fa", "0xc45A67dF151d783Ed4651380DF8154A7924618C1", parcelId);
  
    // Verify the updated ownership of the parcel
    const updatedOwner = await parcelContract.ownerOf(parcelId);
    expect(updatedOwner).to.equal("0xc45A67dF151d783Ed4651380DF8154A7924618C1");
  });
  
  
  
});
