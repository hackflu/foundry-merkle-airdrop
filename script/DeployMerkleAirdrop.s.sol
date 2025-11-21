// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {MerkelAirdrop} from "../src/MerkelAirdop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {Script} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkelRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToTransfer = 4 * 25 * 1e18;

    function run() external returns (MerkelAirdrop, BagelToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkelAirdrop, BagelToken) {
        vm.startBroadcast();
        BagelToken bagelToken = new BagelToken();
        MerkelAirdrop merkelAirdrop = new MerkelAirdrop(s_merkelRoot, IERC20(address(bagelToken)));
        bagelToken.mint(bagelToken.owner(), s_amountToTransfer);
        bagelToken.transfer(address(merkelAirdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (merkelAirdrop, bagelToken);
    }
}
