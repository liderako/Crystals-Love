pragma solidity ^0.4.18;

import 	"browser/Admin.sol";
import 	"browser/SafeMathSale.sol";
import	"browser/WhiteList.sol";

interface 	Token {
	function 	transfer(address _to, uint _value) public returns (bool success);
}

contract 	PreSale is Admin, WhiteList {

	using SafeMathSale for uint;

	Token 	public 	_tokenReward;
	uint 	public	_rate;
	uint 	public	_amountRaised;
	bool 	public 	_crowdSaleClosed;
	bool 	public 	_crowdSaleSuccess;
	uint	public	_startPreSale;
	uint    public  _deadlinePreSale;

	/*
	**   Constants
	*/ 
	uint    public constant MIN_ETHER_RAISED = 600 * 1 ether; /* minimum Ether raised */

	/*
	**   Balances
	*/ 
	mapping(address => uint) private _balanceOf;

	/*
	**   Events
	*/ 
	event 	DepositEther(address owner, uint amount);
	event 	WithdrawEther(address owner, uint amount);
	event   GoalReached(uint amountRaised, bool crowdSaleSuccess);
	
	/*
    **   Constructor
    */
	// "0xa54fbd3339dc1a6082718852072b82dde3403865", "0x627306090abab3a6e1400e9345bc60c78a8bef57", "7000", "10"
	function 	PreSale(address addressOfTokenUsedAsReward, address moderator, uint rate, uint startPresale, uint timeOfDeadLine)
					Admin(msg.sender) WhiteList(moderator) public {
		require(addressOfTokenUsedAsReward != address(0x0));
		require(rate > 0);
		require(startPresale > now);
		require(startPresale < timeOfDeadLine);

		_tokenReward = Token(addressOfTokenUsedAsReward);
		_rate = rate;
		_startPreSale = startPresale;
		_deadlinePreSale = now + timeOfDeadLine * 1 minutes;
	}

	/*
	**	Fallback function for raising ether
	*/ 
	function () external payable {
		uint 	amount;
		uint 	remain;

		require(now >= _startPreSale && now <= _deadlinePreSale);   // check start and deadline of presale
		assertBool(_crowdSaleClosed, true); // check if crowdsale is closed
		assertUserAuthorized(msg.sender);   // check if user is authorized

		amount = msg.value;
		remain = MIN_ETHER_RAISED.sub(_amountRaised);
		require(amount <= remain); // check if remain <= _amountRaised

		_balanceOf[msg.sender] = _balanceOf[msg.sender].add(amount);
		_amountRaised = _amountRaised.add(amount);
		goalManagement();
		_tokenReward.transfer(msg.sender, amount.mul(_rate));
		DepositEther(msg.sender, amount);
	}
	
	/*
	**   Function for check goal reaching
	*/ 
	function 	goalManagement() private {
		if (_amountRaised >= MIN_ETHER_RAISED) { // check current balance
			_crowdSaleClosed = true;
			_crowdSaleSuccess = true;
			GoalReached(_amountRaised, _crowdSaleSuccess);
		}
	}

	/*
	**	Function for withdrawal ether by a authorized user
	**	if crowdsale isn't success
	*/ 
	function    withdrawalMoneyBack() public {
		uint 	amount;

		assertBool(_crowdSaleClosed, false);
		assertBool(_crowdSaleSuccess, true);
		assertUserAuthorized(msg.sender);

		amount = _balanceOf[msg.sender];
		_balanceOf[msg.sender] = 0;
		_amountRaised = _amountRaised.sub(amount);
		msg.sender.transfer(amount);
		WithdrawEther(msg.sender, amount);
	}

	/*
	**	Function for withdrawal ether by admin
	**	if crowdsale is success
	*/ 
	function 	withdrawalAdmin() public {
		uint 	amount;
		assertBool(_crowdSaleClosed, false);
		assertBool(_crowdSaleSuccess, false);
		assertAdmin();
	
		amount = _amountRaised;
		_amountRaised = 0;
		msg.sender.transfer(amount);
		WithdrawEther(msg.sender, amount);
	}
	
	/*
	**	Function for close ICO if it isn't success
	*/
	function    closePreSale() public {
		require(now >= _deadlinePreSale);	/* check Deadline of presale */
		assertBool(_crowdSaleClosed, true);	/* check if crowdsale is closed */
		assertUserAuthorized(msg.sender);

		_crowdSaleClosed = true;
	}
	
	function 	assertBool(bool a, bool b) pure private {
		if (a == b) {
			require(false);
		}
	}
	
}