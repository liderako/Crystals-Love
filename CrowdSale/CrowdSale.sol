pragma solidity ^0.4.21;

import	"./WhiteList.sol";
import 	"./SafeMathSale.sol";

interface 	Token {
	function 	transfer(address _to, uint _value) external returns (bool success);
}

contract 	CrowdSale is WhiteList {

	using SafeMathSale for uint;

	uint 	public	_amountRaised;
	bool 	public 	_saleClosed;
	bool 	public 	_saleSuccess;


	/*
	**   Constants
	*/
	uint    public constant 	MIN_ETHER_RAISED = 600 * 1 ether;
	uint	public constant		_startSale;
	uint    public constant 	_deadLineSale;
	uint 	public constant		_rate = 7000;
	Token 	public constant 	_tokenReward = Token( 0xa54fbd3339dc1a6082718852072b82dde3403865 );
	
	/*
	**   Balances ETH 
	*/
	mapping(address => uint) private _balanceOf;

	/*
	**   Events
	*/
	event 	DepositEther(address owner, uint amount);
	event 	TransferToken(address user, uint amount);
	event 	WithdrawEther(address owner, uint amount);
	event   GoalReached(uint amountRaised, bool saleSuccess);

	function 	CrowdSale() WhiteList(msg.sender) public {
		uint startSale = 10;
		uint endSale = 10;

		_startSale = now + (startSale) * 1 minutes;
		_deadLineSale = now + (endSale + startSale) * 1 minutes;
		require(_startSale < _deadLineSale);
	}

	/*
	**	Fallback function for raising ether
	*/
	function () external payable {
		uint 	amount;
		uint 	remain;


		amount = msg.value;
		require(now >= _startSale && now <= _deadLineSale); /* check start and deadline of presale */
		assertNotBool(_saleClosed, true); /* check if crowdsale is closed */
		require (_balanceDepositEth[msg.sender] == 0);

		remain = MIN_ETHER_RAISED.sub(_amountRaised);
		require(amount <= remain);
		_balanceDepositEth[msg.sender] = amount;
		// _balanceOf[msg.sender] = _balanceOf[msg.sender].add(amount);
		// _amountRaised = _amountRaised.add(amount);
		// goalManagement();
		// _tokenReward.transfer(msg.sender, amount.mul(_rate));
		emit DepositEther(msg.sender, amount);
	}

	function 	transferToken(address user) public {
		assertModerator();
		assertNull(user);
		require (balanceDepositEth[user] != 0);

		uint amount = balanceDepositEth[user];
		_balanceOf[user] = _balanceOf[user].add(amount);
		_amountRaised = _amountRaised.add(amount);
		balanceDepositEth[user] = 0;
		goalManagement();
		_tokenReward.transfer(user, amount.mul(_rate));
		emit TransferToken()
	}
	
	/*
	**   Function for check goal reaching
	*/
	function 	goalManagement() private {
		if (_amountRaised >= MIN_ETHER_RAISED) { // check current balance
			_saleClosed = true;
			_saleSuccess = true;
			emit GoalReached(_amountRaised, _saleSuccess);
		}
	}

	/*
	**	Function for withdrawal ether by a authorized user
	**	if crowdsale isn't success
	*/
	function    withdrawalMoneyBack() public {
		uint 	amount;

		assertNotBool(_saleClosed, false);
		assertNotBool(_saleSuccess, true);
		// assertUserAuthorized(msg.sender);

		amount = _balanceOf[msg.sender];
		_balanceOf[msg.sender] = 0;
		_amountRaised = _amountRaised.sub(amount);
		msg.sender.transfer(amount);
		emit WithdrawEther(msg.sender, amount);
	}

	/*
	**	Function for withdrawal ether by admin
	**	if crowdsale is success
	*/
	function 	withdrawalAdmin() public {
		uint 	amount;

		assertNotBool(_saleClosed, false);
		assertNotBool(_saleSuccess, false);
		assertAdmin();

		amount = _amountRaised;
		_amountRaised = 0;
		msg.sender.transfer(amount);
		emit WithdrawEther(msg.sender, amount);
	}

	/*
	**	Function for close ICO if it isn't success
	*/
	function    closeSale() public {
		require(now >= _deadLineSale);	/* check Deadline of presale */
		assertNotBool(_saleClosed, true);	/* check if crowdsale is closed */
	//	assertUserAuthorized(msg.sender);
		_saleClosed = true;
	}

	function 	assertNotBool(bool a, bool b) pure private {
		if (a == b) {
			revert();
		}
	}

	// function	 assertBalancePayable( uint amountPayable, address user ) view private {
	// 	uint 	amount;

	// 	amount = getBalanceAbailabeEthereum( user );
	// 	if ( amount != amountPayable ) {
	// 		require( false );
	// 	}
	// }
}
