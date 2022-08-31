// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract BSigToken is ERC20, Ownable {
  string private _name = "BSIG Coin";
  string private _symbol = "BSIG";
  uint256 private _totalSupply = 1000000000;
  uint256 private _presaleSupply = 300000000;
  uint256 private _ownerSupply = _totalSupply - _presaleSupply;
  uint256 private _lockPresaleSupply = 0;
  bool private _pause = false;
  bool private _isPreSaleEnded = false;
  mapping (address => presaleData) private _presaleBalances;

  struct presaleData {
    uint256 amount;
    uint256 releaseTime;
  }

  constructor() ERC20(_name, _symbol) {
      _mint(msg.sender, _ownerSupply * 10**uint(decimals()));
  }

  function mintPreSale(address _to, uint256 _amount, uint256 _releaseTime) public onlyOwner onlyPresaleAval {
    require(!_pause, "mint pre-sale is pause");
    require(_releaseTime > block.timestamp);
    require(_amount + _lockPresaleSupply <= _presaleSupply, "mint pre-sale is reached limit");
    
    _presaleBalances[_to].amount += _amount;
    _lockPresaleSupply += _amount;
  }

  function releasePresale(address _to) public {
    require(canReleasePresale(_to), "cannot release transaction now");

    _mint(_to, _presaleBalances[_to].amount * 10**uint(decimals()));
    delete _presaleBalances[_to];
  }

  function canReleasePresale(address _to) public view returns (bool) {
    require(_presaleBalances[_to].amount != 0, "address not found");
    require(block.timestamp >= _presaleBalances[_to].releaseTime, "not time to release");

    return true;
  }

  function getPresaleAmount(address _to) public view returns (uint256) {
    return _presaleBalances[_to].amount;
  }

  function getLockSupply() public view returns (uint256) {
    return _lockPresaleSupply;
  }

  function getPause() public view returns (bool) {
    return _pause;
  }

  function setPause(bool _isPause) public onlyOwner {
    _pause = _isPause;
  }

  modifier onlyPresaleAval() {
    require(!_isPreSaleEnded, "presale is ended");
    _;
  }

  function getPresaleEnded() public view returns (bool) {
    return _isPreSaleEnded;
  }

  function setPresaleAvailable(bool _isEnded) public onlyOwner {
    require(_isPreSaleEnded, "presale ended");

    _isPreSaleEnded = _isEnded;
  }
}
