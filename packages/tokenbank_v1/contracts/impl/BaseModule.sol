/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity ^0.5.11;

import "../lib/ReentrancyGuard.sol";

import "../iface/Wallet.sol";
import "../iface/Module.sol";


/// @title BaseModule
/// @dev This contract implements some common functions that are likely
///      be useful for all modules.
///
/// @author Daniel Wang - <daniel@loopring.org>
///
/// The design of this contract is inspired by Argent's contract codebase:
/// https://github.com/argentlabs/argent-contracts
contract BaseModule is Module, ReentrancyGuard
{
    /// @dev Adds a module to a wallet. Callable only by the wallet owner.
    ///      Note that the module must have NOT been added to the wallet.
    function addModule(
        address wallet,
        address module
        )
        external
        nonReentrant
        onlyStricklyWalletOwner(wallet)
    {
        Wallet(wallet).addModule(module);
    }

    /// @dev Remove a module from a wallet. Callable only by the wallet owner.
    ///      Note that the module must have been added to the wallet.
    function removeModule(
        address wallet,
        address module
        )
        external
        nonReentrant
        onlyStricklyWalletOwner(wallet)
    {
        Wallet(wallet).removeModule(module);
    }

    /// @dev Initializes the module for the given wallet address.
    ///      This function must throw in case of error.
    ///      Note that the current module must have been added to the wallet.
    function initialize(address wallet)
        external
        onlyWallet(wallet)
    {
        bindStaticMethods(wallet);
        emit Initialized(wallet);
    }

    /// @dev Initializes the module for the given wallet address.
    ///      This function must throw in case of error.
    ///      Note that the current module must NOT have been removed from the wallet.
    function terminate(address wallet)
        external
        onlyWallet(wallet)
    {
        unbindStaticMethods(wallet);
        emit Terminated(wallet);
    }

    ///.@dev Gets the list of static methods for binding to wallets.
    ///      Sub-contracts should override this method to provide readonly methods for
    ///      wallet binding.
    /// @return methods A list of static method selectors for binding to the wallet
    ///         when this module is initialized for the wallet.
    function staticMethods()
        public
        pure
        returns (bytes4[] memory methods)
    {
    }

    // ===== internal & private methods =====

    /// @dev Internal method to transact on the given wallet.
    function transact(
        address wallet,
        address to,
        uint    value,
        bytes   memory data
        )
        internal
        returns (bytes memory)
    {
        return Wallet(wallet).transact(to, value, data);
    }

    /// @dev Binds all static methods to the given wallet.
    function bindStaticMethods(address wallet)
        internal
    {
        Wallet w = Wallet(wallet);
        bytes4[] memory methods = staticMethods();
        for (uint i = 0; i < methods.length; i++) {
            w.bindStaticMethod(methods[i], address(this));
        }
    }

    /// @dev Unbinds all static methods from the given wallet.
    function unbindStaticMethods(address wallet)
        internal
    {
        Wallet w = Wallet(wallet);
        bytes4[] memory methods = staticMethods();
        for (uint i = 0; i < methods.length; i++) {
            w.bindStaticMethod(methods[i], address(0));
        }
    }
}
