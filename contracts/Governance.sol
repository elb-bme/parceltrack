// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Parcel.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Manager is Ownable{
  struct SLAData {
        uint256 threshold;
        bool violated;
        string description;
    }

    address private parcelContract;
    mapping(uint256 => SLAData) private _slaData;

    event ParcelRegistered(uint256 indexed tokenId, address owner);
    event HandoverInitiated(uint256 indexed tokenId, address from, address to);
    event HandoverReceived(uint256 indexed tokenId, address from, address to);
    event SLASet(uint256 indexed tokenId, uint256 threshold);
    event SLAViolated(uint256 indexed tokenId);

    constructor(address _parcelContract) {
        parcelContract = _parcelContract;
    }

    function registerParcel(address owner) external onlyOwner {
    uint256 tokenId = parcelContract.getTokenCounter();
    parcelContract.safeMint(owner);

    // Create SLA data for the parcel
    SLAData storage sla = _slaData[tokenId];
    sla.threshold = 0;
    sla.violated = false;

    emit ParcelRegistered(tokenId, owner);
}

    function initiateHandover(uint256 tokenId, address to) external {
        Parcel parcel = Parcel(parcelContract);
        parcel.initiateHandover(tokenId, to);

        address from = parcel.ownerOf(tokenId);
        emit HandoverInitiated(tokenId, from, to);
    }

    function receiveHandover(uint256 tokenId) external {
        Parcel parcel = Parcel(parcelContract);
        parcel.receiveHandover(tokenId);

        address from = parcel.ownerOf(tokenId);
        emit HandoverReceived(tokenId, from, msg.sender);
    }

    function setSLA(uint256 tokenId, uint256 threshold, string calldata description) external {
        require(tokenId > 0, "Invalid token ID");

        _slaData[tokenId].threshold = threshold;
        _slaData[tokenId].description = description;

        emit SLASet(tokenId, threshold);
    }

    function getSLA(uint256 tokenId) external view returns (uint256, bool, string memory) {
        require(tokenId > 0, "Invalid token ID");

        SLAData memory sla = _slaData[tokenId];
        return (sla.threshold, sla.violated, sla.description);
    }

    function checkSLAViolation(uint256 tokenId, uint256 sensorValue) external {
        require(tokenId > 0, "Invalid token ID");

        SLAData storage sla = _slaData[tokenId];
        if (!sla.violated && sensorValue > sla.threshold) {
            sla.violated = true;
            emit SLAViolated(tokenId);
        }
    }
}
