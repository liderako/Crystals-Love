pragma solidity ^0.4.18;

contract Admin {

	address private _admin;
	/* - */
	function 	Admin( address admin ) public {
		assertNULL();
		_admin = admin;
	}
	/* + */
	function 	assertAdmin() internal view returns ( bool ) {
		if ( _admin != msg.sender )
			require( false );
		return true;
	}
	/* - */
	function 	assertNULL() internal view returns ( bool ){
		if ( admin == address( 0x0 ) )
			require( false );
		return true;
	}
	/* + */
	function 	getAdmin() public constant returns( address admin ) {
		return 	_admin;
	}
}
