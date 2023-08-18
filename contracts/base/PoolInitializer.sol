// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '@elkdex/v3-core/contracts/interfaces/IElkDexV3Factory.sol';
import '@elkdex/v3-core/contracts/interfaces/IElkDexV3Pool.sol';

import './PeripheryImmutableState.sol';
import '../interfaces/IPoolInitializer.sol';

/// @title Creates and initializes V3 Pools
abstract contract PoolInitializer is IPoolInitializer, PeripheryImmutableState {
    /// @inheritdoc IPoolInitializer
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable override returns (address pool) {
        require(token0 < token1);
        pool = IElkDexV3Factory(factory).getPool(token0, token1, fee);

        if (pool == address(0)) {
            pool = IElkDexV3Factory(factory).createPool(token0, token1, fee);
            IElkDexV3Pool(pool).initialize(sqrtPriceX96);
        } else {
            (uint160 sqrtPriceX96Existing, , , , , , ) = IElkDexV3Pool(pool).slot0();
            if (sqrtPriceX96Existing == 0) {
                IElkDexV3Pool(pool).initialize(sqrtPriceX96);
            }
        }
    }
}
