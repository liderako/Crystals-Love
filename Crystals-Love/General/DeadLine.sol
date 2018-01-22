pragma solidity ^0.4.18;

contract DeadLine {
	uint public  _deadline;

	function 	DeadLine( uint time ) public {
		_deadline = now + time * 1 minutes;
	}

	function 	assertTime() view internal {
		if ( now <= _deadline )
			require( false );
	}
}