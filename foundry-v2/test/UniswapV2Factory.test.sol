// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import {Test, console2} from "forge-std/Test.sol";
import {DAI, WETH, MKR, UNISWAP_V2_ROUTER_02, UNISWAP_V2_FACTORY} from "../src/Constants.sol";
import {IERC20} from "../src/IERC20.sol";
import {IWETH} from "../src/IWETH.sol";
import {IUniswapV2Router02} from "../src/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "../src/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "../src/IUniswapV2Pair.sol";

import {ERC20} from "../src/ERC20.sol";

contract UniswapV2Factory is Test {
    IWETH private constant weth = IWETH(WETH);
    IUniswapV2Factory private constant factory =
        IUniswapV2Factory(UNISWAP_V2_FACTORY);

    function test_createPair() public {
        ERC20 token = new ERC20("test", "TEST", 18);

        // Exercise - deploy token + WETH pair contract

        address pair = factory.createPair(address(token), WETH);

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        if (address(token) < WETH) {
            assertEq(token0, address(token), "token0");
            assertEq(token1, WETH, "token1");
        } else {
            assertEq(token0, WETH, "token0");
            assertEq(token1, address(token), "token1");
        }
    }
}
