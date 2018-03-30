pragma solidity ^0.4.21;

import 	"./Admin.sol";

contract 	WhiteList is Admin {

	mapping( address => bool ) internal		_moderator;
	mapping( address => uint ) internal		_balanceDepositEth;

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

	function 	getModerator( address user ) public constant returns ( bool ) {
		return 	_moderator[user];
	}

	function 	assertModerator() view internal {
		if ( _moderator[msg.sender] == false )
			require( false );
	}

	function    assertNULL( address user ) pure internal {
		if ( user == address( 0x0 ) )
			 require( false );
	}
}
