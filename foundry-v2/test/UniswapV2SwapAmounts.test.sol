// SPDX-License-Identifier: MIT

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "../src/IERC20.sol";
import {IWETH} from "../src/IWETH.sol";
import {IUniswapV2Router02} from "../src/IUniswapV2Router02.sol";
import {DAI, WETH, MKR, UNISWAP_V2_ROUTER_02} from "../src/Constants.sol";

contract UniswapV2SwapAmountsTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant mkr = IERC20(MKR);

    IUniswapV2Router02 private constant router =
        IUniswapV2Router02(UNISWAP_V2_ROUTER_02);

    function test_getAmountsOut() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;
        uint256 amountIn = 1e18; // 10 ** 18
        uint256[] memory amounts = router.getAmountsOut(amountIn, path);

        console2.log("WETH: %d", amounts[0]);
        console2.log("DAI: %d", amounts[1]);
        console2.log("MKR: %d", amounts[2]);
    }

    function test_getAmountsIn() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;
        uint256 amountOut = 1e18; // 10 ** 18
        uint256[] memory amounts = router.getAmountsIn(amountOut, path);

        console2.log("WETH: %d", amounts[0]);
        console2.log("DAI: %d", amounts[1]);
        console2.log("MKR: %d", amounts[2]);
    }
}
