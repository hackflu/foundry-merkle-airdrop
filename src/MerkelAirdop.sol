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

contract MerkelAirdrop {
    // some list of addresses
    // Allow someone in the list to claim tokens
    // merkel proof
    using SafeERC20 for IERC20;
    ///////////////////
    ///// error //////
    //////////////////

    error MerkelAirdrop__InvalidMerkleProof();
    error MerkelAirdrop__AlreadyClaimed();
    //////////////////
    ///// state //////
    //////////////////

    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;
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
    constructor(bytes32 merkelRoot, IERC20 airdropToken) {
        i_merkleRoot = merkelRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkelProof) external {
        if (s_hasClaimed[account]) {
            revert MerkelAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkelProof, i_merkleRoot, leaf)) {
            revert MerkelAirdrop__InvalidMerkleProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMerkelRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() public view returns (IERC20) {
        return i_airdropToken;
    }
}
