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

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
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

interface ILendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
}

interface Aave {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;
    function borrow(address _reserve, uint256 _amount, uint256 _interestRateModel, uint16 _referralCode) external;
    function getUserBorrowBalance(address _reserve, address _user) external view returns (uint256, uint256, uint256);
    function repay(address _reserve, uint256 _amount, address payable _onBehalfOf) external payable;
}

interface AToken {
    function redeem(uint256 amount) external;
}

interface LendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
    function getLendingPoolCore() external view returns (address);
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

contract iTrade is ERC20, ERC20Detailed, ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  uint256 public pool;

  address public yCurve;
  address public yCurveSwap;

  address public aave;
  address public aavePool;
  address public yAaveToken;

  address public yDAI;
  address public yUSDC;
  address public yUSDT;
  address public yTUSD;

  address public DAI;
  address public USDC;
  address public USDT;
  address public TUSD;

  uint256 public ltv;
  uint256 public base;

  // principal deposits
  mapping (address => mapping (address => uint256)) public principals;

  // debt shares
  mapping (address => mapping (address => uint256)) public debts;
  mapping (address => uint256) public debtsTotalSupply;

  mapping (address => mapping (address => uint256)) public positions;

  constructor () public ERC20Detailed("itrade y.curve.fi", "y.curve.fi", 18) {
    yCurve = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    yCurveSwap = address(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);

    aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
    aavePool = address(0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3);
    yAaveToken = address(0x9bA00D6856a4eDF4665BcA2C2309936572473B7E);

    yDAI = address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01);
    yUSDC = address(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e);
    yUSDT = address(0x83f798e925BcD4017Eb265844FDDAbb448f1707D);
    yTUSD = address(0x73a052500105205d34Daf004eAb301916DA8190f);

    DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    TUSD = address(0x0000000000085d4780B73119b644AE5ecd22b376);

    ltv = uint256(150);
    base = uint256(100);

    approveToken();
  }

  // LP deposit
  function deposit(uint256 _amount)
      external
      nonReentrant
  {
      require(_amount > 0, "deposit must be greater than 0");
      pool = calcPoolValueInToken();

      IERC20(yCurve).safeTransferFrom(msg.sender, address(this), _amount);

      // Calculate collateral pool shares
      uint256 shares = 0;
      if (pool == 0) {
        shares = _amount;
        pool = _amount;
      } else {
        shares = (_amount.mul(totalSupply())).div(pool);
      }
      pool = calcPoolValueInToken();
      _mint(msg.sender, shares);
  }

  // No rebalance implementation for lower fees and faster swaps
  function withdraw(uint256 _shares)
      external
      nonReentrant
  {
      require(_shares > 0, "withdraw must be greater than 0");

      uint256 ibalance = balanceOf(msg.sender);
      require(_shares <= ibalance, "insufficient balance");

      // Could have over value from cTokens
      pool = calcPoolValueInToken();
      // Calc to redeem before updating balances
      uint256 r = (pool.mul(_shares)).div(totalSupply());

      _burn(msg.sender, _shares);

      // Check balance
      uint256 b = IERC20(yCurve).balanceOf(address(this));
      if (b < r) {
        _withdrawSome(r.sub(b));
      }

      IERC20(yCurve).safeTransfer(msg.sender, r);
      pool = calcPoolValueInToken();
  }

  function getAave() public view returns (address) {
      return LendingPoolAddressesProvider(aave).getLendingPool();
  }

  function getAaveCore() public view returns (address) {
      return LendingPoolAddressesProvider(aave).getLendingPoolCore();
  }

  function approveToken() public {
      IERC20(yCurve).safeApprove(getAaveCore(), uint(-1));
  }

  function balance() public view returns (uint256) {
      return IERC20(yCurve).balanceOf(address(this));
  }

  function balanceAaveAvailable() public view returns (uint256) {
      return IERC20(yCurve).balanceOf(aavePool);
  }

  function balanceAave() public view returns (uint256) {
      return IERC20(yAaveToken).balanceOf(address(this));
  }

  function borrowAave(address _reserve, uint256 _amount) public {
      //0x2 = VARIABLE InterestRateModel
      Aave(getAave()).borrow(_reserve, _amount, 2, 7);
  }

  function withdrawCollateral(address _reserve, uint256 _amount) external {
    require(getUserDebt(_reserve, msg.sender) == 0, "itrade: outstanding debt to settle");

    require(_amount <= principals[_reserve][msg.sender], "itrade: insufficient balance");
    require(IERC20(_reserve).balanceOf(address(this)) == 0, "itrade: unexpected result");

    uint256 _price = yERC20(getYToken(_reserve)).getPricePerFullShare();
    uint256 _ytoken = _amount.mul(1e18).div(_price);
    yERC20(getYToken(_reserve)).withdraw(_ytoken);

    require(IERC20(_reserve).balanceOf(address(this)) >= _amount, "itrade: unexpected result");
    principals[_reserve][msg.sender] = principals[_reserve][msg.sender].sub(_amount);

    IERC20(_reserve).safeTransfer(msg.sender, _amount);

    // Cleanup dust (if any)
    if (IERC20(_reserve).balanceOf(address(this)) > 0) {
      yERC20(getYToken(_reserve)).deposit(IERC20(_reserve).balanceOf(address(this)));
    }
  }

  function isLeverage(uint256 leverage) public pure returns (bool) {
      if (leverage == 2||
        leverage == 5||
        leverage == 10||
        leverage == 25||
        leverage == 50||
        leverage == 75||
        leverage == 100||
        leverage == 1000) {
        return true;
      } else {
        return false;
      }
  }

  function addCollateral(address _reserve, address _to, uint256 _amount, uint256 _min_to_amount, uint256 leverage) external {
    require(isLeverage(leverage) == true, "itrade: invalid leverage parameter");
    IERC20(_reserve).safeTransferFrom(msg.sender, address(this), _amount);
    principals[_reserve][msg.sender] = principals[_reserve][msg.sender].add(_amount);
    yERC20(getYToken(_reserve)).deposit(_amount);

    uint256 _borrow = (_amount.mul(leverage)).sub(_amount);
    uint256 _pool = getBorrowDebt(_reserve);
    uint256 _debt = 0;
    if (_pool == 0) {
      _debt = _borrow;
    } else {
      _debt = (_borrow.mul(debtsTotalSupply[_reserve])).div(_pool);
    }
    _mintDebt(_reserve, msg.sender, _debt);
    borrowAave(_reserve, _borrow);

    uint8 _fromID = getCurveID(_reserve);
    uint8 _toID = getCurveID(_to);
    require(IERC20(_to).balanceOf(address(this)) == 0, "itrade: unexpected result");
    ICurveFi(yCurveSwap).exchange_underlying(_fromID, _toID, _borrow, _min_to_amount);
    uint256 _bought = IERC20(_to).balanceOf(address(this));
    positions[_to][msg.sender] = positions[_to][msg.sender].add(_bought);

    yERC20(getYToken(_to)).deposit(_bought);
  }

  function tradePosition(address _reserve, address _to, uint256 _amount, uint256 _min_to_amount) external {
    require(_amount <= positions[_reserve][msg.sender], "itrade: insufficient balance");
    require(IERC20(_reserve).balanceOf(address(this)) == 0, "itrade: unexpected result");

    uint256 _price = yERC20(getYToken(_reserve)).getPricePerFullShare();
    uint256 _ytoken = _amount.mul(1e18).div(_price);
    yERC20(getYToken(_reserve)).withdraw(_ytoken);

    require(IERC20(_reserve).balanceOf(address(this)) >= _amount, "itrade: unexpected result");
    require(IERC20(_to).balanceOf(address(this)) == 0, "itrade: unexpected result");

    uint8 _fromID = getCurveID(_reserve);
    uint8 _toID = getCurveID(_to);

    ICurveFi(yCurveSwap).exchange_underlying(_fromID, _toID, _amount, _min_to_amount);
    positions[_reserve][msg.sender] = positions[_reserve][msg.sender].sub(_amount);
    uint256 _bought = IERC20(_to).balanceOf(address(this));
    positions[_to][msg.sender] = positions[_to][msg.sender].add(_bought);
    yERC20(getYToken(_to)).deposit(_bought);

    // Cleanup dust (if any)
    if (IERC20(_reserve).balanceOf(address(this)) > 0) {
      yERC20(getYToken(_reserve)).deposit(IERC20(_reserve).balanceOf(address(this)));
    }
  }

  function closePosition(address _reserve, uint256 _amount) external {
    require(_amount <= positions[_reserve][msg.sender], "itrade: insufficient balance");
    require(IERC20(_reserve).balanceOf(address(this)) == 0, "itrade: unexpected result");

    uint256 debt = getUserDebt(_reserve, msg.sender);
    uint256 ret = 0;

    if (_amount > debt) {
      ret = _amount.sub(debt);
      _amount = debt;
    }

    uint256 _price = yERC20(getYToken(_reserve)).getPricePerFullShare();
    uint256 _ytoken = _amount.mul(1e18).div(_price);
    yERC20(getYToken(_reserve)).withdraw(_ytoken);

    uint256 shares = debts[_reserve][msg.sender].mul(_amount).div(debt);
    Aave(getAave()).repay(_reserve, _amount, address(uint160(address(this))));
    _burnDebt(_reserve, msg.sender, shares);

    // Profits from trade
    if (ret > 0) {
      IERC20(_reserve).safeTransfer(msg.sender, ret);
    }

    // Cleanup dust (if any)
    if (IERC20(_reserve).balanceOf(address(this)) > 0) {
      yERC20(getYToken(_reserve)).deposit(IERC20(_reserve).balanceOf(address(this)));
    }
  }

  function repayDebt(address _reserve, uint256 _amount) external {
    uint256 debt = getUserDebt(_reserve, msg.sender);
    uint256 ret = 0;

    if (_amount > debt) {
      ret = _amount.sub(debt);
      _amount = debt;
    }

    IERC20(_reserve).safeTransferFrom(msg.sender, address(this), _amount);
    uint256 shares = debts[_reserve][msg.sender].mul(_amount).div(debt);
    Aave(getAave()).repay(_reserve, _amount, address(uint160(address(this))));
    _burnDebt(_reserve, msg.sender, shares);

    if (ret > 0) {
      IERC20(_reserve).safeTransfer(msg.sender, ret);
    }
  }

  function settle(address _reserve) external {
    uint256 _debt = getUserDebt(_reserve, msg.sender);
    IERC20(_reserve).safeTransferFrom(msg.sender, address(this), _debt);
    Aave(getAave()).repay(_reserve, _debt, address(uint160(address(this))));
    _burnDebt(_reserve, msg.sender, debts[_reserve][msg.sender]);
  }

  /*function liquidate(address _reserve, address _user) {
    require(isSafe(_reserve, _user) == false, "itrade: account is safe");
    // Close position (what if position is not in current reserve?)
    // settleDebt

    // Goal: SettleDebt
    // Requires 100k + interest
  }*/

  function isSafe(address _reserve, address _user) public view returns (bool) {
      uint256 _interest = getUserInterest(_reserve, _user);
      uint256 _principal = principals[_reserve][_user];
      return _principal > _interest.mul(ltv).div(base);
  }

  function getUserDebt(address _reserve, address _user) public view returns (uint256) {
      return getBorrowDebt(_reserve).mul(debts[_reserve][_user]).div(debtsTotalSupply[_reserve]);
  }

  function getUserInterest(address _reserve, address _user) public view returns (uint256) {
      return getBorrowInterest(_reserve).mul(debts[_reserve][_user]).div(debtsTotalSupply[_reserve]);
  }

  function getBorrowDebt(address _reserve) public view returns (uint256) {
      (,uint256 compounded,) = Aave(getAave()).getUserBorrowBalance(_reserve, address(this));
      return compounded;
  }

  function getBorrowInterest(address _reserve) public view returns (uint256) {
      (uint256 principal,uint256 compounded,) = Aave(getAave()).getUserBorrowBalance(_reserve, address(this));
      return compounded.sub(principal);
  }

  function supplyAave() public {
      Aave(getAave()).deposit(yCurve, IERC20(yCurve).balanceOf(address(this)), 7);
  }

  function _withdrawSome(uint amount) internal {
      AToken(yAaveToken).redeem(amount);
  }

  function calcPoolValueInToken() public view returns (uint) {
      return balanceAave().add(balance());
  }

  function getPricePerFullShare() public view returns (uint) {
      uint _pool = calcPoolValueInToken();
      return _pool.mul(1e18).div(totalSupply());
  }

  function _mintDebt(address _reserve, address account, uint256 amount) internal {
      require(account != address(0), "ERC20: mint to the zero address");
      debtsTotalSupply[_reserve] = debtsTotalSupply[_reserve].add(amount);
      debts[_reserve][account] = debts[_reserve][account].add(amount);
  }
  function _burnDebt(address _reserve, address account, uint256 amount) internal {
      require(account != address(0), "ERC20: burn from the zero address");
      debts[_reserve][account] = debts[_reserve][account].sub(amount, "ERC20: burn amount exceeds balance");
      debtsTotalSupply[_reserve] = debtsTotalSupply[_reserve].sub(amount);
  }
  function getYToken(address _reserve) public view returns (address) {
      if (_reserve == DAI) {
        return yDAI;
      } else if (_reserve == USDC) {
        return yUSDC;
      } else if (_reserve == USDT) {
        return yUSDT;
      } else if (_reserve == TUSD) {
        return yTUSD;
      }
  }
  function getCurveID(address _reserve) public view returns (uint8) {
      if (_reserve == DAI) {
        return uint8(1);
      } else if (_reserve == USDC) {
        return uint8(2);
      } else if (_reserve == USDT) {
        return uint8(3);
      } else if (_reserve == TUSD) {
        return uint8(4);
      }
  }
  function getCollateral(address _reserve, address _owner) public view returns (uint256) {
      return principals[_reserve][_owner];
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
