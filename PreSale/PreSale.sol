pragma solidity ^0.4.21;

import 	"browser/SafeMathSale.sol";
import	"browser/WhiteList.sol";

interface 	Token {
	function 	transfer( address _to, uint _value ) external returns ( bool success );
}

contract 	PreSale is WhiteList {

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
	**   Balances ETH
	*/
	mapping( address => uint ) private 	_balanceOf;

	/*
	**   Events
	*/
	event 	DepositEther( address owner, uint amount );
	event 	WithdrawEther( address owner, uint amount );
	event   GoalReached( uint amountRaised, bool crowdSaleSuccess );

	/*
	**   Constructor
	*/
	// "0x6ee64d35aa096dd99f93e1ad61b2c681f67eeb09", "0x9257a9687fb222c8ec849eeda38144f328e80834", "7000", "10", "10"
	function 	PreSale( address addressOfTokenUsedAsReward, address admin, uint rate, uint startPreSale, uint minute )
						WhiteList( admin ) public {

		require( addressOfTokenUsedAsReward != address(0x0) );
		require( rate > 0 );

		_tokenReward = Token( addressOfTokenUsedAsReward );
		_rate = rate;
		_startPreSale = now + startPreSale * 1 minutes;
		_deadlinePreSale = now + (minute + startPreSale) * 1 minutes;
		require( _startPreSale < _deadlinePreSale );
	}

	/*
	**	Fallback function for raising ether
	*/
	function () external payable {
		uint 	amount;
		uint 	remain;

		require( now >= _startPreSale && now <= _deadlinePreSale ); /* check start and deadline of presale */
		assertBool( _crowdSaleClosed, true ); /* check if crowdsale is closed */
		assertUserAuthorized( msg.sender );

		amount = msg.value;
		changedAbailabeBalancesUser( amount, msg.sender );
		remain = MIN_ETHER_RAISED.sub( _amountRaised );
		require( amount <= remain );


		_balanceOf[msg.sender] = _balanceOf[msg.sender].add( amount );
		_amountRaised = _amountRaised.add( amount );
		goalManagement();
		_tokenReward.transfer( msg.sender, amount.mul( _rate ) );
		emit DepositEther( msg.sender, amount );
	}

	/*
	**   Function for check goal reaching
	*/
	function 	goalManagement() private {
		if ( _amountRaised >= MIN_ETHER_RAISED ) { // check current balance
			_crowdSaleClosed = true;
			_crowdSaleSuccess = true;
			emit GoalReached( _amountRaised, _crowdSaleSuccess );
		}
	}

	/*
	**	Function for withdrawal ether by a authorized user
	**	if crowdsale isn't success
	*/
	function    withdrawalMoneyBack() public {
		uint 	amount;

		assertBool( _crowdSaleClosed, false );
		assertBool( _crowdSaleSuccess, true );
		assertUserAuthorized( msg.sender );

		amount = _balanceOf[msg.sender];
		_balanceOf[msg.sender] = 0;
		_amountRaised = _amountRaised.sub( amount );
		msg.sender.transfer( amount );
		emit WithdrawEther( msg.sender, amount );
	}

	/*
	**	Function for withdrawal ether by admin
	**	if crowdsale is success
	*/
	function 	withdrawalAdmin() public {
		uint 	amount;

		assertBool( _crowdSaleClosed, false );
		assertBool( _crowdSaleSuccess, false );
		assertAdmin();

		amount = _amountRaised;
		_amountRaised = 0;
		msg.sender.transfer( amount );
		emit WithdrawEther( msg.sender, amount );
	}

	/*
	**	Function for close ICO if it isn't success
	*/
	function    closePreSale() public {
		require( now >= _deadlinePreSale );	/* check Deadline of presale */
		assertBool( _crowdSaleClosed, true );	/* check if crowdsale is closed */
		assertUserAuthorized( msg.sender );

		_crowdSaleClosed = true;
	}
	
	function	 changedAbailabeBalancesUser( uint amountPayable, address user ) private {
		uint 	amount;

		amount = getBalanceAbailabeEthereum( user );
		if ( amount != amountPayable ) {
			require( false );
		}
		_balanceAvailabeEth[user] = 0;
	}
	
	function 	assertBool( bool a, bool b ) pure private {
		if ( a == b ) {
			require( false );
		}
	}
}
