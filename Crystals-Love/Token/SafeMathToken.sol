pragma solidity ^0.4.18;

library SafeMathToken {
	function 	add(uint x, uint y) pure internal returns (uint) {
		uint 	z;

		z = x + y;
		if (z <= x) {
			require(false); /* Overflow */
		}
		return 	z;
	}

	function 	sub(uint x, uint y) pure internal returns (uint) {
		uint 	z;

		z = x - y;
		if (z >= x) {
			require(false); /* Overflow */
		}
		return 	z;
	}
}
