// SPDX-License-Identifier: MIT

// Layout of Contract:
// license
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract MerkelAirdrop is EIP712{
    // some list of addresses
    // Allow someone in the list to claim tokens
    // merkel proof
    using SafeERC20 for IERC20;
    ///////////////////
    ///// error //////
    //////////////////

    error MerkelAirdrop__InvalidMerkleProof();
    error MerkelAirdrop__AlreadyClaimed();
    error MerkelAirdrop__InvalidSignature();
    //////////////////
    ///// state //////
    //////////////////

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256('AirdropClaim(address account , uint256 amount)');
    //////////////////////
    // type declartaion //
    /////////////////////
    struct AirdropClaim {
        address account;
        uint256 amount;
    }
    //////////////////
    ///// events /////
    //////////////////

    event Claim(address indexed account, uint256 amount);
    //////////////////
    ///// modifiers //
    //////////////////

    //////////////////
    ///// functions //
    //////////////////
    constructor(bytes32 merkelRoot, IERC20 airdropToken) EIP712("MerkelAirdrop","1"){
        i_merkleRoot = merkelRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkelProof,uint8 v , bytes32 r ,bytes32 s) external {
        if (s_hasClaimed[account]) {
            revert MerkelAirdrop__AlreadyClaimed();
        }
        // check the signature
        if(!_isValidSignature(account , getMessageHash(account , amount) , v ,r, s)){
            revert MerkelAirdrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkelProof, i_merkleRoot, leaf)) {
            revert MerkelAirdrop__InvalidMerkleProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMessageHash(address account ,uint256 amount) public view returns(bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account : account , amount : amount})))
        );
    }
    function getMerkelRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() public view returns (IERC20) {
        return i_airdropToken;
    }

    function _isValidSignature(address account , bytes32 digest ,uint8 v,bytes32 r,bytes32 s) internal pure returns (bool){
        (address actualSigner ,,) = ECDSA.tryRecover(digest ,v,r,s);
        return actualSigner == account;        
    }
}
