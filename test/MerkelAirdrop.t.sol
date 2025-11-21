// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MerkelAirdrop} from "../src/MerkelAirdop.sol";
import {Test, console} from "forge-std/Test.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkelAirdropTest is Test {
    MerkelAirdrop public merkelAirdrop;
    BagelToken public bagelToken;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT * 4;
    bytes32[] public PROOF = [
        bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];
    address user;
    uint256 userPrivKey;

    function setUp() external {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (merkelAirdrop, bagelToken) = deployer.deployMerkleAirdrop();
        // without script
        // bagelToken = new BagelToken();
        // merkelAirdrop = new MerkelAirdrop(ROOT,bagelToken);
        // bagelToken.mint(bagelToken.owner() , AMOUNT_TO_SEND);
        // bagelToken.transfer(address(merkelAirdrop), AMOUNT_TO_SEND);

        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = bagelToken.balanceOf(user);
        vm.prank(user);
        merkelAirdrop.claim(user, AMOUNT, PROOF);

        uint256 endingBalance = bagelToken.balanceOf(user);
        console.log("ending balance of user :", endingBalance);
        assertEq(endingBalance, startingBalance + AMOUNT);
    }
}
