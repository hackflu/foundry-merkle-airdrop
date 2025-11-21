// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkelAirdrop} from "../src/MerkelAirdop.sol";
import { DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract ClaimAirdrop is Script {
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 proofOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [proofOne, proofTwo];
    bytes SIGNATURE = hex"835b1c0f92029b6b88d34eb21c42f3277f3c26a1ac7c3bf18b598681880d8a0e5cf90722acefff5dfff500d27b37cec2652658fc0d3f95fefa80bfb2795ea20b1c";

    error ClaimAirdrop__InvalidSignature();

    function claimAirdrop(address merkelAirdrop) public {
       vm.startBroadcast();
       (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
       MerkelAirdrop(merkelAirdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, PROOF, v, r, s);
       vm.stopBroadcast();
    } 
    
    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("MerkelAirdrop", block.chainid);
        claimAirdrop(mostRecentDeployed);
    }

    function splitSignature(bytes memory signature) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if(signature.length  != 65){
            revert ClaimAirdrop__InvalidSignature();
        }
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }   
    }
}