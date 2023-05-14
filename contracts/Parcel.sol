// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Parcel is ERC721, Ownable {
    using SafeMath for uint256;

    struct ParcelData {
        address[] sensors;
        mapping(address => bool) sensorStatus;
        mapping(address => uint256) _sensorTokenIds;

    }

    mapping(uint256 => ParcelData) private _parcelData;
    uint256 private _tokenCounter;

    event ParcelRegistered(uint256 indexed tokenId, address owner);
    event HandoverInitiated(uint256 indexed tokenId, address from, address to);
    event HandoverReceived(uint256 indexed tokenId, address from, address to);
    event SensorAdded(uint256 indexed tokenId, address sensor);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function registerParcel() external {
        uint256 tokenId = _getNextTokenId();
        _safeMint(msg.sender, tokenId);

        ParcelData storage parcel = _parcelData[tokenId];
        emit ParcelRegistered(tokenId, msg.sender);
    }

    function initiateHandover(uint256 tokenId, address to) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Only the current owner can initiate a handover");
        require(to != address(0), "Invalid recipient address");

        emit HandoverInitiated(tokenId, msg.sender, to);
        _transfer(msg.sender, to, tokenId);
    }

    function receiveHandover(uint256 tokenId) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) != msg.sender, "You already own the parcel");

        address from = ownerOf(tokenId);
        emit HandoverReceived(tokenId, from, msg.sender);
        _transfer(from, msg.sender, tokenId);
    }
    
    function getTokenCounter() public view returns (uint256) {
        return _tokenCounter;
    }
    // Helper function to get the next token ID
    function _getNextTokenId() public returns (uint256) {
        _tokenCounter = _tokenCounter.add(1);
        return _tokenCounter;
    }

    function getNextTokenId() external returns (uint256) {
        return _getNextTokenId();
    }

    // Function to set the token ID associated with a sensor address
    function setSensorTokenId(address sensorAddress, uint256 tokenId) external onlyOwner {
    require(sensorAddress != address(0), "Invalid sensor address");
    require(tokenId > 0, "Invalid token ID");

    ParcelData storage parcel = _parcelData[tokenId];
    parcel._sensorTokenIds[sensorAddress] = tokenId;    
    }


        // Function to get the token ID associated with a sensor address
    function getSensorTokenId(address sensor) public view returns (uint256) {
        uint256 tokenId = 0;
        for (uint256 i = 1; i <= _tokenCounter; i++) {
            if (_exists(i) && _parcelData[i].sensorStatus[sensor]) {
                tokenId = i;
                break;
            }
        }
        return tokenId;
    }

    function safeMint(address to) public {
        _tokenCounter = _tokenCounter.add(1);
        _safeMint(to, _tokenCounter);
    }

    // Override balanceOf function from ERC721
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "Invalid address");
        return super.balanceOf(owner);
    }

    // Override ownerOf function from ERC721
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "Token does not exist");
        return super.ownerOf(tokenId);
    }

    // Override safeTransferFrom function from ERC721
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        require(to != address(0), "Invalid recipient address");
        super.safeTransferFrom(from, to, tokenId);
    }

    function addSensor(uint256 tokenId, address sensor) external onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        require(sensor != address(0), "Invalid sensor address");

        ParcelData storage parcel = _parcelData[tokenId];
        require(!parcel.sensorStatus[sensor], "Sensor already added");

        parcel.sensors.push(sensor);
        parcel.sensorStatus[sensor] = true;

        emit SensorAdded(tokenId, sensor);
    }

    // Override transferFrom function from ERC721
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        require(to != address(0), "Invalid recipient address");
        super.transferFrom(from, to, tokenId);
    }
}