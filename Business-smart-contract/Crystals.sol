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

contract Admin {

	address private _admin;

	function 	Admin( address admin ) public {
		if ( admin == address( 0x0 ) )
			require( false );
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

contract Moderators is Admin {
	mapping (address => bool) 	private _moderator;
	/*
 	** The function is available only admin.
	** Function sets value in mapping moderator.
	** If msg.sender != admin, then revert transaction.
	** If @param true, then user moderator.
	** If @param false, then user no moderator.
	** If user = 0x0, then revert transaction.
	*/
	function	changeStatusModerator(address user, bool status) public {
		assertAdmin();
		assertNULL(user);
		_moderator[user] = status;
	}

	function 	getModerator(address user) public constant returns (bool) {
		return 	_moderator[user];
	}

	function    assertNULL(address user) pure internal {
		if (user == address(0x0)) {
			 revert();
		}
	}

	function 	assertModerator() view internal {
		if (_moderator[msg.sender] == false) {
			revert();
		}
	}
	function 	assertAdms(address sender) returns(bool res) internal {
		if (sender != getAdmin() || getModerator(sender) != true) {
			revert();
		}
	}
	
}

contract AdminPanel is Moderators, Admin {
	mapping(uint => address) private _executor;
// добавить адрес смарт-контракта токена
	function 	AdminPanel(address admin) public Admin(admin) { }

	function 	getExecutor(uint id) public constant returns (address) {
		assertAdms();
		returns _executor[id];
	}
	

	function 	setExecutor(uint id, address user) public returns (bool) {
		assertAdms(msg.sender);
		require(getExecutor(id) == (0x0));
		_executor[id] = user;
		return true;
	}

	function 	deleteExecutor(uint id) public returns (bool) {
		assertAdms(msg.sender);
		require(getExecutor(id) != (0x0));
		_executor[id] = 0x0;
		return true;
	}
}

contract Crystals is SafeMath, AdminPanel {
	mapping(address => mapping(address => uint)) public _tokens;

	function 	Crystals() public AdminPanel(msg.sender) {}
	

	// депозит под ERC20 под наш ERC827 возможно можно другое прописать
	// нам в принципе не нужен адрес токена
	function 	depositTokensInWallet(address token, uint amount) public {
		assertToken(token);
		assertQuantity(amount);
	// сделать баланс отдельно
	// изменить на один токен системы
	//	_tokens[token][msg.sender] = safeAdd(_tokens[token][msg.sender], amount);
		if (Token(token).transferFrom(msg.sender, this, amount) == false) {
			revert();
		}
	}
	// завести деньги в личный баланс
	function 	withdrawTokensFromWallet(address token, uint amount) public {
		assertToken(token);
		assertQuantity(amount);

		// изменить на один токен системы
		//	_tokens[token][msg.sender] = safeSub(_tokens[token][msg.sender], amount);
		if (Token(token).transfer(msg.sender, amount) == false) {
			revert();
		}
	}

	// Этот метод должен переводит токены из смарт-контракта маппинга _tokens на замороженое состояние для исполнителя
	function 	transferTokensForExecutor(uint id, uint amount) public {
		// assertToken(token);
		// assertQuantity(amount);
		// _tokens[token][msg.sender] = safeAdd(_tokens[token][msg.sender], amount);
		// if (Token(token).transferFrom(msg.sender, this, amount) == false) {
			// revert();
		// }

		// Как должен генерироваться конверт для исполнителя???? 
		// 1. Хеш
		// 2. .....
	}
//	 нам в принципе не нужен адресс токена
// 	Этот метод должен завести деньги из вне смарт-контракта в конверт для исполнителя
	function 	depositTokensForExecutor(address token, uint amount) public{
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
