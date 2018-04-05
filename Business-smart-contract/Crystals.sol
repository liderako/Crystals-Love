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

	struct Strongbox{
		uint 	id;
		address user;
		uint 	amount;		
	}
	
	mapping(uint => address) 	private _executor;
	mapping(address => uint) 	private _balanceOf;
	mapping(bytes32 => Strongbox) private _strongboxList;
	
	address 					private	_addressTokenSmartContract;
	
	function 	AdminPanel(address admin, address token) public Admin(admin) {
		require(token != (0x0));
		_addressTokenSmartContract = token;
	}

	function 	getAddressTokenSmartContract() public constant returns (address) {
		returns _addressTokenSmartContract;
	}

	function 	_balanceOf(address user) public constant returns (address) {
		returns _balanceOf[user];
	}

	/* Функции для работы с исполнителем */
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

	/* Функции для работы со сейфом */


	/* Пока все функции публично открыти и любой может по хешу узнать что-то кроме адреса исполнителя*/
	// можно ограничить только для администраторов
	// для исполнителя и для юзера который создал этот конверт
	function 	setStrongBox(bytes32 hash, uint id, address user, uint amount) private {
		_strongboxList[hash].id = id;
		_strongboxList[hash].amount = amount;
		_strongboxList[hash].user = user;
	}

	function 	setAmount(bytes32 hash, uint amount) private {	
		_strongboxList[hash] = amount;
	}
	
	function 	getId(bytes32 hash) public constant returns (uint) {
		return _strongboxList[hash].id;
	}
	function 	getAmount(bytes32 hash) public constant returns (uint) {
		return _strongboxList[hash].amount;
	}
	function 	getUser(bytes32 hash) public constant returns (address) {
		return _strongboxList[hash].user;
	}
}

contract Crystals is SafeMath, AdminPanel {

	function 	Crystals(address token) public AdminPanel(msg.sender, token) {}
	

	// депозит под ERC20, под наш ERC827 возможно есть более лучшее решение
	/* Функция для того чтобы завести деньги на личный баланс в смарт-контракте*/
	function 	depositTokensInWallet(uint amount) public {
		require (amount != 0);
		_balanceOf[msg.sender] = safeAdd(_balanceOf[msg.sender], amount);
		if (Token(getAddressTokenSmartContract()).transferFrom(msg.sender, this, amount) == false) {
			revert();
		}
	}

	/* Функция для того чтобы вывести деньги с личного баланса обратно на адрес msg.sender*/
	function 	withdrawTokensFromWallet(uint amount) public {
		require (amount != 0);
		_balanceOf[msg.sender] = safeSub(_balanceOf[msg.sender], amount);
		if (Token(getAddressTokenSmartContract()).transfer(msg.sender, amount) == false) {
			revert();
		}
	}

	/* Этот метод должен переводит токены из внутринего баланса на замороженое состояние для исполнителя */
	function 	transferTokensForExecutor(uint id, uint amount) public {
		createStrongBox(id, amount);
		_balanceOf[msg.sender] = safeSub(_balanceOf[msg.sender], amount);
	}

	// доп функционал на потом
	// /* 	Метод для того чтобы завести токены на замороженое состояние исполнителя из внешнего баланса. */
	// function 	depositTokensForExecutor(int amount) public {
	// }

	//  Метод для того чтобы добавить токенов на замороженом состоянии для исполнителя из внешнего баланса
	// function 	additionalDepositTokensForExecutor(int amount) public {
		
	// }

	/* Метод для того чтобы добавить токенов на замороженом состоянии для исполнителя из внутринего баланса*/
	// проверить функционал на работу
	function 	additionalTransferTokensForExecutor(uint id, int amount) public {
		bytes32 	hash;

		// require (id != 0);
		// require (amount != 0);
		require (getExecutor(id) != (0x0));
		hash = sha256(this, id, msg.sender);
		require (getId(hash) != 0);
		setAmount(safeAdd(getAmount(hash), amount));
		_balanceOf[msg.sender] = safeSub(_balanceOf[msg.sender], amount);
	}
	// проверить функционал на работу
	function 	createStrongBox(uint id, uint amount) private {
		bytes32 	hash;

		require(getExecutor(id) != (0x0));
		hash = sha256(this, id, msg.sender);
		require(getId(hash) == 0); // если уже занят хеш тогда нельзя создавать еще конверт. Вероятность этого существует при повторном создании с этим же исполнителем договорености
		setStrongBox(hash, id, msg.sender, amount)
	}

	// проверить функционал на работу
	function 	cancelStrongBox(uint id) private {
		bytes32 	hash;

		require(getExecutor(id) != (0x0));
		hash = sha256(this, id, msg.sender);
		require(getId(hash) != 0); // проверка на то что заявка существовала
		setStrongBox(hash, id, msg.sender, amount)
	}
	// добавить функционал для соглашение юзера передать деньги для исполнителя
}
