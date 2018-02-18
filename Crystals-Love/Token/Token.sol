pragma solidity ^0.4.18;

import 	"browser/ERC20.sol";
import 	"browser/Admin.sol";

contract Token is ERC20, Admin {
	uint 	private _freezingTokens;
	uint 	public  _deadline; // Later named another name

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
		 _deadline = now + time * 1 minutes;
	}

	function 	addBurnAddress( address user ) public returns ( bool ) {
		assertAdmin();

		_burnAddress[user] = true;
		return 	true;
	}

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
	    require( amount != 0);
		require( _balanceOf[msg.sender] >= amount );
		require( _burnAddress[msg.sender] == true );

		_balanceOf[msg.sender] = sub( _balanceOf[msg.sender], amount );
		_totalSupply = sub( _totalSupply, amount );
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
		if (now <= _deadline) {
			require(false);
		}
	}
}
