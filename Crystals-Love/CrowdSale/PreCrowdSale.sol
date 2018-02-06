pragma solidity ^0.4.18;

import 	"browser/Admin.sol";
import 	"browser/SafeMathSell.sol";
import	"browser/WhiteList.sol";

interface 	Token {
	function 	transfer(address _to, uint256 _value) public returns (bool success);
}

contract 	PreCrowdSale is Admin, WhiteList {

	using SafeMathSell for uint256;

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
	// "0x671d481e28f3e9bdf525f43ae656cd668f71aebb", "0x627306090abab3a6e1400e9345bc60c78a8bef57", "72", "10"
	function 	PreCrowdSale(address addressOfTokenUsedAsReward, address moderator, uint rate, uint timeOfDeadLine)
					Admin(msg.sender) WhiteList(moderator) public payable {
		require(addressOfTokenUsedAsReward != address(0x0));
		require(rate > 0);

		_tokenReward = Token(addressOfTokenUsedAsReward);
		_rate = rate;
		_startPreSale = now;
		_deadlinePreSale = now + timeOfDeadLine * 1 minutes;
	}

	/*
	**	Fallback function for raising ether
	*/ 
	// need test
	function () external payable {
		uint 	amount;
		uint 	remain;

		require(now >= _startPreSale && now <= _deadlinePreSale);   // check start and deadline of presale
		assertBool(_crowdSaleClosed, true); // check if crowdsale is closed
		assertUserAuthorized(msg.sender);   // check if user is authorized

		amount = msg.value;
		remain = MIN_ETHER_RAISED - _amountRaised;
		require(amount <= remain); // check if remain <= _amountRaised

		_balanceOf[msg.sender] = _balanceOf[msg.sender].add(amount);
		_amountRaised = _amountRaised.add(amount);
		_tokenReward.transfer(msg.sender, amount.mul(_rate));
		goalManagement(amount);
	}
	
	/*
	**   Function for check goal reaching
	*/ 
	function 	goalManagement(uint amount) public {
		if (_amountRaised >= MIN_ETHER_RAISED) { // check current balance
			_crowdSaleClosed = true;
			_crowdSaleSuccess = true;
			GoalReached(_amountRaised, _crowdSaleSuccess);
		}
		DepositEther(msg.sender, amount);
	}

	/*
	**	Function for withdrawal ether by a authorized user
	**	if crowdsale isn't success
	*/ 
	/* need test */
	function    withdrawalMoneyBack() public payable {
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
	// need test
	function 	withdrawalAdmin() public payable {
		assertBool(_crowdSaleClosed, false);
		assertBool(_crowdSaleSuccess, false);
		assertAdmin();

		_amountRaised = 0;
		msg.sender.transfer(_amountRaised);
		WithdrawEther(msg.sender, _amountRaised);
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
