pragma solidity ^0.4.18;

contract 	WhiteList {
	
	//TODO: Add and delete moderator. This right belong to admin. Or add mapping of moderators

	address public	_moderator;
	
	mapping ( address => bool ) internal _listAuthorizedUser;
	/* - */
	function 	WhiteList( address moderator ) public {
		require( moderator != address( 0x0 ) );
		_moderator = moderator;
	}
	/* - */
	function 	setAuthorizeUser( address user ) public {	
		require( user != address( 0x0 ) );
		assertModerator();

		_listAuthorizedUser[user] = true;
	}
	/* + */
	function 	getAuthorizeUser( address user ) public constant returns( bool ) {
		return 	_listAuthorizedUser[user];
	}
	/* + */
	function 	assertModerator() view internal {
		if ( msg.sender != _moderator )
			require( false );
	}
	/* + */
	function 	assertUserAuthorized( address user ) view internal {
		if ( _listAuthorizedUser[user] == false )
			require( false );
	}
}
