pragma solidity =0.5.16;

import './interfaces/IUniswapV2Factory.sol';
import './UniswapV2Pair.sol';

contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        // NOTE: sort token by address
        // 1 byte = 2 hexadecimal characters = 8 bits
        // address <-> 20 bytes hexadecimal <-> 160 bit number
        // 0x742d35Cc6634C0532925a3b844Bc454e4438f44e <-> 663483689693157230503816352273506655749142638350
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        // NOTE: creation code (creationCode) = runtime code + constructor arguments
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        // NOTE: deploy with create2 - UniswapV2Library.pairFor
        // NOTE: create2 addr <- keccak256(0xff ++ deployer ++ salt ++ keccak256(creation bytecode))
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            // using create2 to deloy contract with creation code and constructor arguments
            // NOTE: pair = address(new UniswapV2Pair{salt: salt}())
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
