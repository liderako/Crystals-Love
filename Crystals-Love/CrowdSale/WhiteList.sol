pragma solidity ^0.4.18;

import 	"browser/Admin.sol";

contract 	WhiteList is Admin {

	mapping( address => bool ) public		_moderator;
	mapping( address => bool ) internal	_listAuthorizedUser;

	/*
	** If moderator == 0x0, then revert moderator.
	*/
	function 	WhiteList( address admin ) public Admin( admin ){
		assertNULL( admin );
	}

	/*
	** Add the user to the whitelist.
	** The function is available only moderator.
	** If user == 0x0, then revert transaction.
	**/
	function 	setAuthorizeUser( address user ) public {
		assertNULL( user );
		assertModerator();

		_listAuthorizedUser[user] = true;
	}
	/*
	** Add the moderator
	** The function is available only admin.
	** If user = 0x0, then revert transaction.
	*/
	function	setModerator( address moderator ) public {
		assertAdmin();
		assertNULL( moderator );

		_moderator[moderator] = true;
	}
	/*
	** This function deleting moderator.
	** Function is available only admin.
	** If user = 0x0, then revert transaction.
	*/
	function	deleteModerator( address moderator ) public {
		assertAdmin();
		assertNULL( moderator );

		_moderator[moderator] = false;
	}

	function 	getAuthorizeUser( address user ) public constant returns( bool ) {
		return 	_listAuthorizedUser[user];
	}

	function 	assertModerator() view internal {
		if ( _moderator[msg.sender] == false )
			require( false );
	}

	function 	assertUserAuthorized( address user ) view internal {
		if ( _listAuthorizedUser[user] == false )
			require( false );
	}

	function    assertNULL( address user ) pure internal {
	    if ( user == address( 0x0 ))
	        require( false );
	}
}
