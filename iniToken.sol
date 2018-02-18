pragma solidity ^0.4.18;

contract SafeMathToken {
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

/* ----------------------------------------------------------------------------------------------
* Sample fixed supply token contract
* Enjoy. (c) BokkyPooBah 2017. The MIT Licence.
* ----------------------------------------------------------------------------------------------
*
* ERC Token Standard #20 Interface
* https://github.com/ethereum/EIPs/issues/20
*/
interface IERC20 {

	// Get the total token supply
	function 	totalSupply() public constant returns ( uint supply );

	// Get the account balance of another account with address _owner
	function 	balanceOf( address _owner ) public constant returns ( uint balance );

	// Send _value amount of tokens to address _to
	function 	transfer( address _to, uint _value ) public returns ( bool success );

	// Send _value amount of tokens from address _from to address _to
	function 	transferFrom( address _from, address _to, uint _value ) public returns ( bool success );

	// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
	// If this function is called again it overwrites the current allowance with _value.
	// this function is required for some DEX functionality
	function 	approve( address _spender, uint _value ) public returns ( bool success );

	// Returns the amount which _spender is still allowed to withdraw from _owner
	function 	allowance( address _owner, address _spender ) public constant returns ( uint remaining );

	// Triggered when tokens are transferred.
	event 		Transfer( address indexed _from, address indexed _to, uint _value );

	// Triggered whenever approve(address _spender, uint _value) is called.
	event 		Approval( address indexed _owner, address indexed _spender, uint _value );
}

contract 	ERC20 is SafeMathToken, IERC20 {
	uint	public _totalSupply;
	string 	public	_name;
	string	public	_symbol;
	uint8	public	_decimals;

	mapping ( address => uint )							public _balanceOf;
	mapping ( address => mapping ( address => uint ) )	public _allowance;

	function 	ERC20( string nameToken, string symbolToken, uint supply, uint8 decimals ) public {
		uint 	balance;

		balance = supply * 10 ** uint( decimals );
		_name = nameToken;
		_symbol = symbolToken;
		_balanceOf[msg.sender] = balance;
		_totalSupply = balance;
		_decimals = decimals;
	}

	function 	totalSupply() public constant returns ( uint ) {
		return _totalSupply;
	}

	function 	balanceOf( address user ) public constant returns ( uint ) {
		return _balanceOf[user];
	}

	function 	allowance( address owner, address spender ) public constant returns ( uint ) {
		return _allowance[owner][spender];
	}

	function 	transfer( address to, uint amount ) public returns ( bool ) {
		require(_balanceOf[msg.sender] >= amount);

		_balanceOf[msg.sender] = sub( _balanceOf[msg.sender], amount );
		_balanceOf[to] = add( _balanceOf[to], amount );

		Transfer( msg.sender, to, amount );
		return true;
	}

	function 	transferFrom( address from, address to, uint amount ) public returns ( bool ) {
		require( _balanceOf[from] >= amount );
		require( _allowance[from][msg.sender] >= amount );

		_allowance[from][msg.sender] = sub( _allowance[from][msg.sender], amount );
		_balanceOf[from] = sub( _balanceOf[from], amount );
		_balanceOf[to] = add( _balanceOf[to], amount );

		Transfer( from, to, amount );
		return true;
	}

	function 	approve( address spender, uint amount ) public returns ( bool ) {
		_allowance[msg.sender][spender] = amount;

		Approval( msg.sender, spender, amount );
		return true;
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

contract Token is ERC20, Admin {
	uint 	private _freezingTokens;
	uint 	public  _deadlineForToken; // Later named another name

	mapping (address => bool) public _burnAddress;

	event 	FreezingTokens(address admin, uint amount);
	event 	DefrostingTokens(address admin, uint amount);
	event 	Burn(address indexed from, uint value);

	/*
	*	"NameToken","SSS","42000000","18", "5"
	*	construct for remix solidity
	*/
	function 	Token(string nameToken, string symbolToken, uint supply, uint8 decimals, uint time)
				ERC20(nameToken, symbolToken, supply, decimals) Admin(msg.sender) public {
		 _deadlineForToken = now + time * 1 minutes;
	}
	// changed
	function 	addBurnAddress( address user ) public returns ( bool ) {
		assertAdmin();

		_burnAddress[user] = true;
		return 	true;
	}
	// changed
	function 	deleteBurnAddress( address user ) public returns ( bool ) {
		assertAdmin();

		_burnAddress[user] = false;
		return 	true;
	}

	function 	freezingTokens(uint amount)  public returns (bool) {
		assertAdmin();

		if (_balanceOf[getAdmin()] < amount || amount == 0) {
			require( false );
		}
		if ( _freezingTokens > 0 ) {
		    require( false );
		}
		amount = amount * (10 ** uint( _decimals ));
		_balanceOf[getAdmin()] = sub( _balanceOf[getAdmin()], amount );
		_freezingTokens = amount;
		FreezingTokens(getAdmin(), amount);
		return 	true;
	}


	function 	defrostingTokens() public returns (bool) {
		uint 	amount;

		assertAdmin();
		assertTimeFrosing();

		amount = _freezingTokens;
		_freezingTokens = 0;
		_balanceOf[getAdmin()] = add( _balanceOf[getAdmin()], amount );

		DefrostingTokens(getAdmin(), amount);
		return 	true;
	}
	/*
	* 	This is function need for burn tokens crowdSale.
	* 	@param uint amount tokens for burn.
	*/
	function 	burn( uint amount ) public returns ( bool ) {
		require( _balanceOf[msg.sender] >= amount );
		require( _burnAddress[msg.sender] == true ); // need test

		_balanceOf[msg.sender] = sub( _balanceOf[msg.sender], amount );
		_totalSupply = sub( _balanceOf[msg.sender], amount );
		Burn( msg.sender, amount );
		return true;
	}

	function	getFreezingTokens() public constant returns ( uint amount ) {
		return _freezingTokens / (10 ** uint( _decimals ));
	}

	function	getNow() public constant returns(uint) {
		return now;
	}

	function	assertTimeFrosing() view internal {
		if (now <= _deadlineForToken) {
			require(false);
		}
	}
}
