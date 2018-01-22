pragma solidity ^0.4.18;

contract 	WhiteList {
	address public	_moderator;
	
	mapping ( address => bool ) internal _listAuthorizedUser;
	/* + */
	function 	WhiteList( address moderator ) public {
		_moderator = moderator;
	}
	/* + */
	function 	setAuthorizeUser( address user ) public {	
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
