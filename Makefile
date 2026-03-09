#######################################
#        FOUNDry PRO MAKEFILE        #
#######################################

.DEFAULT_GOAL := help

#######################################
#            CONFIGURATION            #
#######################################

include .env

NETWORK ?= anvil
SCRIPT ?= script/Deploy.s.sol:DeployScript

ANVIL_RPC_URL = http://127.0.0.1:8545
# SEPOLIA_RPC_URL = $(SEPOLIA_RPC_URL)
# MAINNET_RPC_URL = $(MAINNET_RPC_URL)

#######################################
#              HELP MENU              #
#######################################

help:
	@echo ""
	@echo "========== Foundry Makefile =========="
	@echo ""
	@echo "make build              - Compile contracts"
	@echo "make test               - Run tests"
	@echo "make test-verbose       - Run tests with -vvvv"
	@echo "make coverage           - Run coverage"
	@echo "make gas                - Generate gas snapshot"
	@echo "make clean              - Clean build artifacts"
	@echo "make format             - Format contracts"
	@echo ""
	@echo "make anvil              - Start local node"
	@echo ""
	@echo "make deploy NETWORK=anvil"
	@echo "make deploy NETWORK=sepolia"
	@echo "make deploy NETWORK=mainnet"
	@echo ""
	@echo "make verify NETWORK=sepolia ADDRESS=0x..."
	@echo ""
	@echo "======================================="
	@echo ""

#######################################
#         BASIC DEVELOPMENT           #
#######################################

.PHONY: build test test-verbose coverage gas clean format

build:
	forge build

test:
	forge test

test-verbose:
	forge test -vvvv

coverage:
	forge coverage

gas:
	forge snapshot

format:
	forge fmt

clean:
	forge clean

#######################################
#         LOCAL DEVELOPMENT           #
#######################################

anvil:
	anvil

#######################################
#         DEPLOYMENT LOGIC            #
#######################################

deploy:
ifeq ($(NETWORK),anvil)
	forge script $(SCRIPT) \
		--rpc-url $(ANVIL_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast
endif

ifeq ($(NETWORK),sepolia)
	forge script $(SCRIPT) \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY)
endif

ifeq ($(NETWORK),mainnet)
	forge script $(SCRIPT) \
		--rpc-url $(MAINNET_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY)
endif

#######################################
#         CONTRACT VERIFICATION       #
#######################################

verify:
ifeq ($(NETWORK),sepolia)
	forge verify-contract \
		--chain-id 11155111 \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		$(ADDRESS) \
		src/YourContract.sol:YourContract
endif

ifeq ($(NETWORK),mainnet)
	forge verify-contract \
		--chain-id 1 \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		$(ADDRESS) \
		src/YourContract.sol:YourContract
endif

fork-test:
	forge test --fork-url $(SEPOLIA_RPC_URL)