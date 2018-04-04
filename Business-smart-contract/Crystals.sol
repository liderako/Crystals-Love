pragma solidity ^0.4.21;

contract Token {
	function transfer(address _to, uint256 _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

library SafeMath {
	function safeAdd(uint a, uint b) internal pure returns (uint) {
		uint 	c;

		c = a + b;
		assert(c >= a && c >= b);
		return c;
	}
}

contract Crystals {

	mapping(bytes32 => mapping(address => uint)) public _tokens;

	// депозит под ERC20 под наш ERC827 возможно можно другое прописать
	function 	depositToken( address token, uint amount) public {
		assertToken(token);
		assertQuantity(amount);
		_tokens[token][msg.sender] = safeAdd(_tokens[token][msg.sender], amount);
		if (Token(token).transferFrom(msg.sender, this, amount) == false) {
			revert();
		}
	}

	function 	withdrawToken(address token, uint amount) public {
		assertToken(token);
		assertQuantity(amount);

		_tokens[token][msg.sender] = safeSub(_tokens[token][msg.sender], amount);
		if (Token(token).transfer(msg.sender, amount) == false) {
			revert();
		}
	}

	function 	assertQuantity(uint amount) private pure {
		if (amount == 0) {
			revert();
		}
	}

	function 	assertToken(address token) private pure {
		if (token == 0) {
			revert();
		}
	}
}
