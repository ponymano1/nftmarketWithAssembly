// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Test, console} from "forge-std/Test.sol";




contract NFTMarket is IERC721Receiver{
    using SafeERC20 for IERC20;
    
    IERC20 private immutable _token;
    IERC721 private immutable _nft;
     
    //uint256 public a = 1;
    address private _admin;

    mapping(uint256 => uint256) private _prices;
    mapping(uint256 => address) private _owners;

    error NotOwner(address addr);
    error NotApproved(uint256 tokenId);
    error NotListed(uint256 tokenId);
    error NotEnoughToken(uint256 value, uint256 price);
    error ErrorSignature();
    error Expired();
    error NotAdmin();
    error NotPermitBuyer();

    event List(uint256 indexed tokenId, address from, uint256 price);
    event Sold(uint256 indexed tokenId, address from, address to, uint256 price);

    constructor(IERC20 token_, IERC721 nft_) {
        _token = token_;
        _nft = nft_;
        _admin = msg.sender;
    }

    function onERC721Received(address, address, uint256, bytes calldata) pure external override 
        returns (bytes4) {
        return this.onERC721Received.selector;
    }

    modifier OnlyNFTOwner(uint256 tokenId) {
        if (_nft.ownerOf(tokenId) != msg.sender) {
            revert NotOwner(msg.sender);
        }
        _;
    }

    modifier OnlyListed(uint256 tokenId) {
        if (_prices[tokenId] == 0) {
            revert NotListed(tokenId);
        }
        _;
    }

    function list(uint256 tokenId, uint256 price) public {
        _nft.safeTransferFrom(msg.sender, address(this), tokenId);
        _prices[tokenId] = price;
        _owners[tokenId] = msg.sender;
        emit List(tokenId, msg.sender, price);
    }

    function getPrice(uint256 tokenId) public view returns (uint256) {
        return _prices[tokenId];
    }

    function getOwner(uint256 tokenId) public view returns (address) {
        return _owners[tokenId];
    }

    function buy(uint256 tokenId) public OnlyListed(tokenId) {
        uint256 price = _prices[tokenId];
        address owner = _owners[tokenId];
        _prices[tokenId] = 0;
        _owners[tokenId] = address(0);
        _token.safeTransferFrom(msg.sender, owner, price);

        _nft.safeTransferFrom(address(this), msg.sender, tokenId);
        emit Sold(tokenId, owner, msg.sender, price);
    }

    function read(bytes32 slot) external  view returns(bytes32 data){
        assembly {
            data := sload(slot) // load from store    
        }
    }

    function read(uint256 slot) external  view returns(bytes32 data){
        assembly {
            data := sload(slot) // load from store    
        }
    }
    function write(bytes32 slot,uint256 value) external {
        assembly{
            sstore(slot, value)
        }
    }
    


    function readAdmin() public view returns (address) {
        bytes32 data;
        assembly {
            data := sload(0)
        }

        return address(uint160(uint256(bytes32(data))));
    } 

    function writeAdmin(address admin) external {
        assembly {

            sstore(0, admin)
        }
    }


    
}
