// (-(-_-(-_(-_(-_-)_-)-_-)_-)_-)-)
// (-(-_-(-_(-_(-_-)_-)-_-)_-)_-)-)
// (-(-_-(-_(-_(-_-)_-)-_-)_-)_-)-)
// (-(-_-(-_(-_(-_-)_-)-_-)_-)_-)-)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20FlashMintUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/// @custom:security-contact conspiracy@bdut.ch
contract Conspiracy is
  Initializable,
  ERC20Upgradeable,
  ERC20BurnableUpgradeable,
  ERC20PausableUpgradeable,
  OwnableUpgradeable,
  ERC20PermitUpgradeable,
  ERC20VotesUpgradeable,
  ERC20FlashMintUpgradeable,
  ReentrancyGuardUpgradeable
{
  // State
  uint256 public mintRate;
  uint256 public supplyCap;
  uint256 public amountMinted;
  address public god;

  // sender => ticketType => claimed
  mapping(uint256 => mapping(uint256 => bool)) public claimed;

  // Events
  event MintRateSet(uint256 newMintRate);
  event SupplyCapSet(uint256 newSupplyCap);
  event GodSet(address newGod);
  event Shh(address indexed sender);
  event Tssss(address indexed sender);
  event Shhhhhh(address indexed sender, uint256 ticketType, uint256 amount);

  function initialize(
    address initialOwner,
    string calldata name,
    string calldata symbol,
    uint256 initialMintRate,
    uint256 initialSupplyCap,
    address initialGod
  ) public initializer {
    mintRate = initialMintRate;
    supplyCap = initialSupplyCap;
    god = initialGod;

    __ERC20_init(name, symbol);
    __ERC20Burnable_init();
    __ERC20Pausable_init();
    __Ownable_init(initialOwner);
    __ERC20Permit_init(name);
    __ERC20Votes_init();
    __ERC20FlashMint_init();
  }

  function setMintRate(uint256 newMintRate) public onlyOwner {
    mintRate = newMintRate;
    emit MintRateSet(newMintRate);
  }

  function setSupplyCap(uint256 newSupplyCap) public onlyOwner {
    supplyCap = newSupplyCap;
    emit SupplyCapSet(newSupplyCap);
  }

  function setGod(address newGod) public onlyOwner {
    god = newGod;
    emit GodSet(newGod);
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function withdraw() public onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  function mint() public payable nonReentrant {
    require(msg.value > 0, "No Ether sent");
    uint256 amountToMint = msg.value * mintRate;
    require(amountMinted + amountToMint <= supplyCap, "Supply cap exceeded");
    amountMinted += amountToMint;
    _mint(msg.sender, amountToMint);
  }

  function shh() public {
    emit Shh(msg.sender);
  }

  function tssss() public {
    emit Tssss(msg.sender);
  }

  function claim(
    bytes calldata data,
    bytes32 r,
    bytes32 vs
  ) public nonReentrant {
    (address recoveredGod, ECDSA.RecoverError ecdsaError, ) = ECDSA.tryRecover(
      MessageHashUtils.toEthSignedMessageHash(data),
      r,
      vs
    );
    require(
      ecdsaError == ECDSA.RecoverError.NoError,
      "Error while verifying the ECDSA signature"
    );
    require(recoveredGod == god, "we don't believe in false prophets");
    (uint256 sender, uint256 ticketType, uint256 amount) = abi.decode(
      data,
      (uint256, uint256, uint256)
    );
    require(
      !claimed[sender][ticketType],
      "You have already claimed this ticket"
    );
    _mint(msg.sender, amount);
    claimed[sender][ticketType] = true;
    emit Shhhhhh(msg.sender, ticketType, amount);
  }

  // The following functions are overrides required by Solidity.

  function _update(
    address from,
    address to,
    uint256 value
  )
    internal
    override(ERC20Upgradeable, ERC20PausableUpgradeable, ERC20VotesUpgradeable)
  {
    super._update(from, to, value);
  }

  function nonces(
    address owner
  )
    public
    view
    override(ERC20PermitUpgradeable, NoncesUpgradeable)
    returns (uint256)
  {
    return super.nonces(owner);
  }
}
