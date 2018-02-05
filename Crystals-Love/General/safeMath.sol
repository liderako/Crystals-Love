pragma solidity ^0.4.18;

contract safeMath {
	
	function 	add( uint x, uint y ) pure internal returns ( uint ) {
		uint 	z;

		z = x + y;
		if ( z <= x ) {
			require( false ); /* Overflow */
		}
		return 	z;
	}

	function 	sub( uint x, uint y ) pure internal returns ( uint ) {
		uint 	z;

		z = x - y;
		if ( z >= x ) {
			require( false ); /* Overflow */
		}
		return 	z;
	}

	function 	mul( uint a, uint b ) internal pure returns ( uint256 ) {
		uint 	c;

		if (a == 0) {
			return 0;
		}
		c = a * b;
		if ( c / a != b ) {
			require( false ); /* Owerflow */ // Check it assert(c / a == b);
		}
		return c;
	}
}
