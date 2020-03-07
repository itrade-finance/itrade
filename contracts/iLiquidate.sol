pragma solidity ^0.5.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface ICurveFi {
  function exchange_underlying(
    int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount
  ) external;
}

interface yERC20 {
  function deposit(uint256 _amount) external;
  function withdraw(uint256 _amount) external;
  function getPricePerFullShare() external view returns (uint256);
}

interface iBorrower {
  function borrowAave(address _reserve, uint256 _amount) external;
  function getBorrowDebt(address _reserve) external view returns (uint256);
  function getBorrowInterest(address _reserve) external view returns (uint256);
  function repayAave(address _reserve, uint256 _amount) external;
  function getYToken(address _reserve) external view returns (address);
  function getCurveID(address _reserve) external view returns (uint8);
  function isLeverage(uint256 leverage) external view returns (bool);
  function isReserve(address _reserve) external view returns (bool);
}

interface iLedger {
  function mintDebt(address _reserve, address account, uint256 amount) external;
  function burnDebt(address _reserve, address account, uint256 amount) external;
  function mintPrincipal(address _reserve, address account, uint256 amount) external;
  function burnPrincipal(address _reserve, address account, uint256 amount) external;
  function mintPosition(address _reserve, address account, uint256 amount) external;
  function burnPosition(address _reserve, address account, uint256 amount) external;
  function getUserInterest(address _reserve, address _user) external view returns (uint256);
  function getUserDebt(address _reserve, address _user) external view returns (uint256);
  function getDebt(address _reserve, address _user) external view returns (uint256);
  function getPosition(address _reserve, address _user) external view returns (uint256);
  function getPrincipal(address _reserve, address _user) external view returns (uint256);
  function getTotalDebt(address _user) external view returns (uint256);
  function getTotalPosition(address _user) external view returns (uint256);
  function getTotalPrincipal(address _user) external view returns (uint256);
}

contract iLiquidate is ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  address public constant yDAI = address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01);
  address public constant yUSDC = address(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e);
  address public constant yUSDT = address(0x83f798e925BcD4017Eb265844FDDAbb448f1707D);
  address public constant yTUSD = address(0x73a052500105205d34Daf004eAb301916DA8190f);

  address public constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  address public constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  address public constant USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  address public constant TUSD = address(0x0000000000085d4780B73119b644AE5ecd22b376);

  iBorrower public constant collateral = iBorrower(0xaCD746993f60e807fBf69F646e42DaedA63a4CfC);
  iLedger public constant ledger = iLedger(0xaCD746993f60e807fBf69F646e42DaedA63a4CfC);

  uint256 public constant ltv = uint256(50);
  uint256 public constant base = uint256(100);

  constructor() public {

  }

  function seize(address _user) external nonReentrant {
      require(isSafe(_user) == false, "itrade: account is safe");

      _seizeReserve(DAI, _user);
      _seizeReserve(USDC, _user);
      _seizeReserve(USDT, _user);

      require(isSafe(msg.sender) == true, "itrade: account would liquidate");
      require(isSafe(_user) == true, "itrade: account would liquidate");
  }

  function _seizeReserve(address _reserve, address _user) internal {
      uint256 _principal = ledger.getPrincipal(_reserve,_user);
      if (_principal > 0) {
        uint256 _debt = ledger.getDebt(_reserve,_user);
        uint256 _position = ledger.getPosition(_reserve,_user);

        ledger.mintPrincipal(_reserve, _user, _principal);
        ledger.burnDebt(_reserve, _user, _debt);
        ledger.burnPosition(_reserve, _user, _position);

        ledger.mintPrincipal(_reserve, msg.sender, _principal);
        ledger.mintDebt(_reserve, msg.sender, _debt);
        ledger.mintPosition(_reserve, msg.sender, _position);
      }
  }

  function isSafe(address _user) public view returns (bool) {
      uint256 _debt = getAllDebt(_user);
      uint256 _position = ledger.getTotalPosition(_user);
      uint256 _collateral = ledger.getTotalPrincipal(_user);
      if (_position >= _debt) {
        return true;
      } else {
        uint256 _diff = _debt.sub(_position);
        uint256 _adjDebt = _diff.mul(ltv).div(base);
        if (_collateral >= _adjDebt) {
          return true;
        } else {
          return false;
        }
      }
  }

  function getAllDebt(address _user) public view returns (uint256) {
      return ledger.getUserDebt(DAI, _user).add(ledger.getUserDebt(USDC, _user)).add(ledger.getUserDebt(USDT, _user));
  }

  // incase of half-way error
  function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {
      uint qty = _TokenAddress.balanceOf(address(this));
      _TokenAddress.safeTransfer(msg.sender, qty);
  }
  // incase of half-way error
  function inCaseETHGetsStuck() onlyOwner public{
      (bool result, ) = msg.sender.call.value(address(this).balance)("");
      require(result, "transfer of ETH failed");
  }
}
