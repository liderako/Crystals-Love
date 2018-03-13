pragma solidity ^0.4.18;

contract SafeMathToken {
	function add( uint a, uint b ) internal pure returns ( uint ) {
		uint c;

		c = a + b;
		assert( c >= a ); /* protected Owerflow */
		return c;
	}

	function sub( uint a, uint b ) internal pure returns ( uint ) {
			assert( b <= a ); /* protected Owerflow */
			return a - b;
	}
}
