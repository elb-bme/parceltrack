// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "truffle/Assert.sol";
import "../contracts/Parcel.sol";

contract TestParcelHandover {
    Parcel parcel;
    address owner = address(0x123);
    uint256 weight = 100;
    uint256 value = 500;
    string content = "test content";
    address[] sensors = new address[](2);
    address[] slas = new address[](1);

    function beforeEach() public {
        parcel = new Parcel();
        sensors[0] = address(0x456);
        sensors[1] = address(0x789);
        slas[0] = address(0xABC);
        parcel.registerParcel(owner, weight, value, content, sensors, slas);
    }

    function testHandoverParcel() public {
        address newReceiver = address(0xDEF);
        parcel.handoverParcel(newReceiver);
        Assert.equal(parcel.getCurrentOwner(), newReceiver, "Parcel owner should match the new receiver");
        Assert.equal(parcel.getHandoverStatus(), Parcel.HandoverStatus.WaitingForReceiverAcknowledge, "Parcel handover status should be WaitingForReceiverAcknowledge");
    }

    function testReceiverAcknowledgesHandover() public {
        address newReceiver = address(0xDEF);
        parcel.handoverParcel(newReceiver);
        parcel.receiverAcknowledgesHandover();
        Assert.equal(parcel.getHandoverStatus(), Parcel.HandoverStatus.Completed, "Parcel handover status should be Completed after receiver acknowledges handover");
    }

    function testInitiateHandoverOnlyByOwner() public {
        address newReceiver = address(0xDEF);
        parcel.transferOwnership(address(this));
        bool success = address(parcel).call(abi.encodeWithSignature("handoverParcel(address)", newReceiver));
        Assert.isFalse(success, "Non-owner should not be able to initiate handover");
        Assert.equal(parcel.getCurrentOwner(), address(this), "Parcel owner should still be the original owner");
    }

    function testReceiverAddressIsValid() public {
        address invalidReceiver = address(0x0);
        bool success = address(parcel).call(abi.encodeWithSignature("handoverParcel(address)", invalidReceiver));
        Assert.isFalse(success, "Invalid receiver address should not be accepted");
        Assert.equal(parcel.getCurrentOwner(), owner, "Parcel owner should still be the original owner");
    }
}
