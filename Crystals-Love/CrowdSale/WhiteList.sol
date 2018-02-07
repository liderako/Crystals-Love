pragma solidity ^0.4.18;

contract 	WhiteList {
	
	//TODO: Add and delete moderator. This right belong to admin. Or add mapping of moderators

	address public	_moderator;
	
	mapping ( address => bool ) internal _listAuthorizedUser;
	
	/*
	** If moderator == 0x0, then revert moderator.
	*/
	function 	WhiteList( address moderator ) public {
		assertNULL( moderator );
		_moderator = moderator;
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
	
	function 	getAuthorizeUser( address user ) public constant returns( bool ) {
		return 	_listAuthorizedUser[user];
	}

	function 	assertModerator() view internal {
		if ( msg.sender != _moderator )
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
