pragma solidity ^0.4.18;

contract Admin {

	address private _admin;

	function 	Admin( address admin ) public {
		_admin = admin;
	}

	function 	assertAdmin() internal view returns ( bool ) {
		if ( _admin != msg.sender )
			require( false );
		return true;
	}

	function 	getAdmin() public constant returns( address admin ) {
		return 	_admin;
	}
}
