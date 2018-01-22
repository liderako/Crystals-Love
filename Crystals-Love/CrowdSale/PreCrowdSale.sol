pragma solidity ^0.4.18;

import 	"browser/Admin.sol";
import 	"browser/DeadLine.sol";
import 	"browser/SafeMath.sol";
import	"browser/WhiteList.sol";

interface 	token {
	function 	transfer(address _to, uint256 _value) public returns (bool success);
	function 	burn( uint256 value ) public returns ( bool success );
	function 	balanceOf( address user ) public view returns ( uint256 );
}

contract 	PreCrowdSale is Admin, WhiteList, SafeMath, DeadLine {
	token 	public 	_tokenReward;
	uint 	public	_price;
	uint 	public	_amountRaised;
	bool 	public 	_crowdSaleClosed;
	bool 	public 	_crowdSaleSuccess;

	mapping( address => uint ) public 	_balanceOf;

	event 	DepositEther( address user, uint amount );
	event 	WithdrawEther( address user, uint amount );
	
	function 	CrowdSale( address addressOfTokenUsedAsReward, address moderator, uint price, uint timeOfDeadLine )
		public 	Admin( msg.sender ) WhiteList( moderator ) DeadLine( timeOfDeadLine ) {
		_tokenReward = token( addressOfTokenUsedAsReward );
		_price = price;
	}
	// need test
	function () public payable {
		uint 	amount;
		uint 	nowBalance;

		assertTime();
		assertBool( _crowdSaleClosed, true );
		assertUserAuthorized( msg.sender );

		amount = msg.value;
		_balanceOf[msg.sender] = add( _balanceOf[msg.sender], amount );
		_amountRaised = add( _amountRaised, amount );
		_tokenReward.transfer( msg.sender, amount / _price );
		goalManagment();
		DepositEther( msg.sender, amount );
	}
	function 	goalManagmentUser() view private {
		uint 	nowBalance;

		nowBalance = _tokenReward.balanceOf( this );
		if ( nowBalance == 0 ) {
			_crowdSaleClosed = true;
			_crowdSaleSuccess = true;
		}
	}
	
	// function 	goalManagment( bool statement ) public {
	// 	assertBool(crowdsaleClosed, false);
	// 	assertAdmin();

	// 	crowdsaleClosed = true;
	// 	crowdsaleSuccess = statement;
	// 	//GoalReached(beneficiary, amountRaised, crowdsaleSuccess);
	// }
	/* need test */
	function    withdrawalMoneyBack() public {
		uint 	amount;

		assertBool( _crowdSaleClosed, false );
		assertBool( _crowdSaleSuccess, true );

		amount = _balanceOf[msg.sender];
		_balanceOf[msg.sender] = 0;
		_amountRaised = sub( _amountRaised, amount );
		msg.sender.transfer( amount );

		WithdrawEther( msg.sender, amount );
	}
	// need test
	function 	withdrawalAdmin() public {
		assertBool( _crowdSaleClosed, false );
		assertBool( _crowdSaleSuccess, false );
		assertAdmin();

		msg.sender.transfer( _amountRaised );
		burnToken();
		WithdrawEther( msg.sender, _amountRaised );
	}
	// need test
	function 	burnToken() private {
		uint 	amount;

		amount = _tokenReward.balanceOf( this );
		_tokenReward.burn( amount );
	}
	// need test
	function 	assertBool( bool a, bool b ) pure private {
		if ( a == b ) {
			require( false );
		}
	}
}
