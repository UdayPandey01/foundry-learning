// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UdayCoin} from "../src/UdayCoin.sol";

contract TestUdayCoin is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);
    UdayCoin c;

    function setUp() public {
        c = new UdayCoin(100);
    }

    function test_Mint() public {
        c.mint(address(this), 10);
        assertEq(c.balanceOf(address(this)), 110);
        assertEq(c.totalSupply(), 110);
    }

    function testTransfer() public {
        c.mint(address(this), 100);
        c.transfer(address(1), 100);
        assertEq(c.balanceOf(address(this)), 100);
        assertEq(c.balanceOf(address(1)), 100);

        vm.prank(address(1));
        c.transfer(address(this), 100);
        assertEq(c.balanceOf(address(this)), 200);
        assertEq(c.balanceOf(address(1)), 0);
    }

    function testTransferEmit() public {
        c.mint(address(this), 100);
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(this), address(1), 100);
        c.transfer(address(1), 100);
    }
}
