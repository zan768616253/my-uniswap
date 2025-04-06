// SPDX-License-Identifier: MIT

import {Test, console2} from "forge-std/Test.sol";
import {DAI, WETH, MKR, UNISWAP_V2_ROUTER_02} from "../src/Constants.sol";
import {IERC20} from "../src/IERC20.sol";
import {IWETH} from "../src/IWETH.sol";
import {IUniswapV2Router02} from "../src/IUniswapV2Router02.sol";

contract UniswapV2SwapTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant mkr = IERC20(MKR);

    IUniswapV2Router02 private constant router =
        IUniswapV2Router02(UNISWAP_V2_ROUTER_02);

    address private constant user = address(100);

    function setUp() public {
        deal(user, 100 * 1e18);
        vm.startPrank(user);

        weth.deposit{value: 100 * 1e18}();
        weth.approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_swapExactTokensForTokens() public {
        address[] memory path = new address[](3);

        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint amountIn = 1e18;
        uint amountOutMin = 0;

        vm.startPrank(user);
        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            user,
            block.timestamp
        );

        console2.log("WETH: %d", amounts[0]);
        console2.log("DAI: %d", amounts[1]);
        console2.log("MKR: %d", amounts[2]);

        assertGe(mkr.balanceOf(user), amountOutMin, "MKR balance of user");

        vm.stopPrank();
    }

    function test_swapTokensForExactTokens() public {
        address[] memory path = new address[](3);

        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint amountOut = 0.1 * 1e18;
        uint amountInMax = 1e18;

        vm.startPrank(user);
        uint256[] memory amounts = router.swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            user,
            block.timestamp
        );

        console2.log("WETH: %d", amounts[0]);
        console2.log("DAI: %d", amounts[1]);
        console2.log("MKR: %d", amounts[2]);

        assertEq(mkr.balanceOf(user), amountOut, "MKR balance of user");

        vm.stopPrank();
    }
}
