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

interface borrower {
  function borrowAave(address _reserve, uint256 _amount) external;
  function getBorrowDebt(address _reserve) external view returns (uint256);
  function getBorrowInterest(address _reserve) external view returns (uint256);
  function repayAave(address _reserve, uint256 _amount) external;
  function getYToken(address _reserve) external view returns (address);
  function getCurveID(address _reserve) external view returns (uint8);
  function isLeverage(uint256 leverage) external view returns (bool);
  function isReserve(address _reserve) external view returns (bool);
}

contract iLedger is ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  borrower public constant collateral = borrower(0xaCD746993f60e807fBf69F646e42DaedA63a4CfC);

  uint256 public constant ltv = uint256(120);
  uint256 public constant base = uint256(100);
  address public trader;

  // principal deposits
  mapping (address => uint256) totalPrincipals;
  mapping (address => mapping (address => uint256)) public principals;

  // debt shares
  mapping (address => mapping (address => uint256)) public debts;
  mapping (address => uint256) public debtsTotalSupply;

  mapping (address => uint256) public totalPositions;
  mapping (address => mapping (address => uint256)) public positions;

  modifier onlyTrader() {
      require(trader == msg.sender, "itrade: caller is not the trader");
      _;
  }
  function transferTrader(address newTrader) public onlyOwner {
      _transferTrader(newTrader);
  }
  function _transferTrader(address newTrader) internal {
      require(newTrader != address(0), "itrade: new trader is the zero address");
      trader = newTrader;
  }

  constructor() public {

  }

  function getDebt(address _reserve, address _user) external view returns (uint256) {
    return debts[_reserve][_user];
  }
  function getPosition(address _reserve, address _user) external view returns (uint256) {
    return positions[_reserve][_user];
  }
  function getPrincipal(address _reserve, address _user) external view returns (uint256) {
    return principals[_reserve][_user];
  }

  function getTotalDebt(address _reserve) external view returns (uint256) {
    return debtsTotalSupply[_reserve];
  }
  function getTotalPosition(address _user) external view returns (uint256) {
    return totalPositions[_user];
  }
  function getTotalPrincipal(address _user) external view returns (uint256) {
    return totalPrincipals[_user];
  }

  function getUserDebt(address _reserve, address _user) public view returns (uint256) {
      if (debtsTotalSupply[_reserve] == 0) {
        return 0;
      } else {
        return collateral.getBorrowDebt(_reserve).mul(debts[_reserve][_user]).div(debtsTotalSupply[_reserve]);
      }
  }
  function getUserInterest(address _reserve, address _user) public view returns (uint256) {
      if (debtsTotalSupply[_reserve] == 0) {
        return 0;
      } else {
        return collateral.getBorrowInterest(_reserve).mul(debts[_reserve][_user]).div(debtsTotalSupply[_reserve]);
      }
  }
  function mintDebt(address _reserve, address account, uint256 amount) external onlyTrader {
      require(account != address(0), "Debt: mint to the zero address");
      debtsTotalSupply[_reserve] = debtsTotalSupply[_reserve].add(amount);
      debts[_reserve][account] = debts[_reserve][account].add(amount);
  }
  function burnDebt(address _reserve, address account, uint256 amount) external onlyTrader {
      require(account != address(0), "Debt: burn from the zero address");
      debts[_reserve][account] = debts[_reserve][account].sub(amount, "Debt: burn amount exceeds balance");
      debtsTotalSupply[_reserve] = debtsTotalSupply[_reserve].sub(amount);
  }
  function mintPrincipal(address _reserve, address account, uint256 amount) external onlyTrader {
      require(account != address(0), "Principal: mint to the zero address");
      totalPrincipals[_reserve] = totalPrincipals[_reserve].add(amount);
      principals[_reserve][account] = principals[_reserve][account].add(amount);
  }
  function burnPrincipal(address _reserve, address account, uint256 amount) external onlyTrader {
      require(account != address(0), "Principal: burn from the zero address");
      principals[_reserve][account] = principals[_reserve][account].sub(amount, "Principal: burn amount exceeds balance");
      totalPrincipals[_reserve] = totalPrincipals[_reserve].sub(amount);
  }
  function mintPosition(address _reserve, address account, uint256 amount) external onlyTrader {
      require(account != address(0), "Position: mint to the zero address");
      totalPositions[_reserve] = totalPositions[_reserve].add(amount);
      positions[_reserve][account] = positions[_reserve][account].add(amount);
  }
  function burnPosition(address _reserve, address account, uint256 amount) external onlyTrader {
      require(account != address(0), "Position: burn from the zero address");
      positions[_reserve][account] = positions[_reserve][account].sub(amount, "Position: burn amount exceeds balance");
      totalPositions[_reserve] = totalPositions[_reserve].sub(amount);
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
