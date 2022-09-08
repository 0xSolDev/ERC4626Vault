//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniswapV2Router.sol";

contract Vault is ERC4626, Ownable {
    address router;

    constructor(
        ERC20 underlying_,
        string memory name_,
        string memory symbol_,
        address router_
    ) ERC20(name_, symbol_) ERC4626(underlying_) {
        router = router_;
    }

    //address of the sushiswap v2 router
    address private constant SUSHISWAP_V2_ROUTER =
        0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function swap(
        address[] memory path,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external onlyOwner {
        IERC20(path[0]).approve(SUSHISWAP_V2_ROUTER, _amountIn);

        IUniswapV2Router(SUSHISWAP_V2_ROUTER).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function swapTokensForETH(
        address token,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline
    ) external onlyOwner {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = WETH;
        IERC20(token).approve(SUSHISWAP_V2_ROUTER, amountIn);
        IUniswapV2Router(SUSHISWAP_V2_ROUTER).swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }
}
