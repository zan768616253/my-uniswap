// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IUniswapV2Pair} from "../src/IUniswapV2Pair.sol";
import {IERC20} from "../src/IERC20.sol";

contract UniswapFlashSwap {
    IUniswapV2Pair private immutable pair;
    address private immutable token0;
    address private immutable token1;

    constructor(address _pair) {
        pair = IUniswapV2Pair(_pair);
        token0 = pair.token0();
        token1 = pair.token1();
    }

    function flashSwap(address token, uint256 amount) external {
        require(
            token == address(token0) || token == address(token1),
            "Invalid token"
        );

        // 1. Determine amount0Out and amount1Out
        (uint256 amount0Out, uint256 amount1Out) = token == token0
            ? (amount, uint256(0))
            : (uint256(0), amount);

        // 2. Encode token and msg.sender as bytes
        bytes memory data = abi.encode(token, msg.sender);

        // 3. Call the pair.swap function
        pair.swap({
            amount0Out: amount0Out,
            amount1Out: amount1Out,
            to: address(this),
            data: data
        });
    }

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        // 1. Require msg.sender is the pair contract
        // 2. Require sender is the contract itself

        // Alice -> FlashSwap ---- to = FlashSwap ----> UniswapV2Pair
        //                    <-- sender = FlashSwap --
        // Eve ------------ to = FlashSwap -----------> UniswapV2Pair
        //              FlashSwap <-- sender = Eve ----

        require(msg.sender == address(pair), "not pair");
        require(sender == address(this), "not sender");

        // 3. Decode token and msg.sender from data
        (address token, address caller) = abi.decode(data, (address, address));

        // 4. Determine amount borrowed (only one of them is > 0)
        uint256 amount = token == token0 ? amount0 : amount1;

        // 5. Calculate the fee
        // fee = borrowed amount * 3 / 997 + 1 to round up
        uint256 fee = (amount * 3) / 997 + 1;
        uint amountToRepay = amount + fee;

        // 6. Get flash swap fee from caller
        IERC20(token).transferFrom(caller, address(this), fee);
        // 7. Repay Uniswap V2 pair
        IERC20(token).transfer(address(pair), amountToRepay);
    }
}
