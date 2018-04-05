pragma solidity ^0.4.21;

contract Token {
	function transfer(address _to, uint256 _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract SafeMath {
	function safeAdd(uint a, uint b) internal pure returns (uint) {
		uint 	c;

		c = a + b;
		assert(c >= a && c >= b);
		return c;
	}
	function safeSub( uint a, uint b ) internal pure returns ( uint ) {
			assert( b <= a );
			return a - b;
	}
}

contract Crystals is SafeMath {
	mapping(address => uint) public _balanceOf;


	// доп функционал на потом
	// /* 	Метод для того чтобы завести токены на замороженое состояние исполнителя из внешнего баланса. */
	function 	depositTokensForExecutor(int amount) public {
		
	}

	 // Метод для того чтобы добавить токенов на замороженом состоянии для исполнителя из внешнего баланса
	function 	additionalDepositTokensForExecutor(int amount) public {
		
	}
}