// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {TimelessToken} from "../src/TimelessToken.sol";

contract TimelessTokenTest is Test {
    uint256 public constant MAX_SUPPLY = 1_000_000_000 ether;
    uint256 public constant INITIAL_SUPPLY = 550_000_000 ether;

    address owner;
    address minter;

    TimelessToken token;

    function setUp() public {
        // set up accounts
        owner = makeAddr("owner");
        minter = makeAddr("minter");

        // deploy contracts
        token = new TimelessToken("Timeless Influence Token", "TIT", owner, minter);
    }

    function test_initialSupply() public {
        assertEqDecimal(token.balanceOf(owner), INITIAL_SUPPLY, 18, "owner doesn't have the initial supply");
    }

    function test_onlyMinterCanMint(uint256 amount, address hacker) public {
        vm.assume(hacker != minter);
        amount = bound(amount, 0, MAX_SUPPLY - INITIAL_SUPPLY);

        // try minting as non minter
        vm.startPrank(hacker);
        vm.expectRevert(bytes4(keccak256("TimelessToken__NotMinter()")));
        token.mint(address(this), amount);
        vm.stopPrank();

        // mint as the minter
        vm.prank(minter);
        token.mint(address(this), amount);

        // verify balance
        assertEqDecimal(token.balanceOf(address(this)), amount, 18, "minted amount incorrect");
    }

    function test_onlyOwnerCanSetMinter(address hacker, address newMinter) public {
        vm.assume(hacker != owner);

        // try setting minter as hacker
        vm.startPrank(hacker);
        vm.expectRevert("UNAUTHORIZED");
        token.setMinter(hacker);
        vm.stopPrank();

        // set minter as the owner
        vm.prank(owner);
        token.setMinter(newMinter);

        // verify new minter
        assertEq(token.minter(), newMinter, "didn't set minter");
    }
}
