pragma solidity ^0.4.21;

import 	"./Admin.sol";

contract 	AdminPanel is Admin {

	mapping(address => bool) internal		_moderator;
	mapping(address => uint) internal		_balanceDepositEth; // баланс эфира который был заведен на смарт-контракт но не получен взамен токены
	mapping(address => uint) internal		_timeBeforeMoneyBack; // время до возможности вернуть свой эфир

	/*
	** Construct.
	** If @param admin == 0x0, then revert transaction.
	*/
	function 	WhiteList( address admin ) public Admin( admin ){
		assertNULL( admin );
	}

	/*
 	** The function is available only admin.
	** Function sets value in mapping moderator.
	** If msg.sender != admin, then revert transaction.
	** If @param true, then user moderator.
	** If @param false, then user no moderator.
	** If user = 0x0, then revert transaction.
	*/
	function	changeStatusModerator( address user, bool status ) public {
		assertAdmin();
		assertNULL( user );

		_moderator[user] = status;
	}

	function 	getModerator(address user) public constant returns (bool) {
		return 	_moderator[user];
	}

	function 	getBalanceDepositEth(address user) public constant returns (uint) {	
		return _balanceDepositEth[user];
	}

	function 	getTimeBeforeMoneyBack(address user) public constant returns (uint) {
		return _timeBeforeMoneyBack[user];	
	}

	function 	setBalanceDepositEth(address user, uint amount) internal {
		require(amount != 0);
		_balanceDepositEth[user] = amount;
	}	

	function 	setTimeBeforeMoneyBack(address user, uint amountTime) internal {
		require(amount != 0);
		// _timeBeforeMoneyBack[user] = now + amountTime * 1 day; // for deploy
		_timeBeforeMoneyBack[user] = now + amountTime * 1 minutes;// for testing 
	}

	function 	assertModerator() view internal {
		if (_moderator[msg.sender] == false)
			revert();
	}

	function    assertNULL(address user) pure internal {
		if (user == address(0x0)) {
			 revert();
		}
	}
}
