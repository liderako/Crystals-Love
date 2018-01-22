pragma solidity ^0.4.18;

import 	"browser/ERC20.sol";
import 	"browser/Admin.sol";
import 	"browser/DeadLine.sol";

contract CrystalsLove is ERC20, Admin, DeadLine {
	address public 	_crowdSale;
	bool	public 	_editEnd;
	uint 	public 	_freezingTokens;

	event 	Burn( address indexed from, uint value );
	event 	FreezingTokens( address admin, uint amount );
	event 	DefrostingTokens( address admin, uint amount );

	/* 
	*	"NameToken","SSS","1000","18","5"
	*	construct for remix solidity
	*/ 
	function 	CrystalsLove( string nameToken, string symbolToken, uint supply, uint8 decimals, uint time )
		public 	ERC20( nameToken, symbolToken, supply, decimals )
		        Admin( msg.sender ) DeadLine( time ) {
	}
	/* + */
	function 	setAddressCrowdSale( address smartContract ) public returns ( bool ) {
		assertAdmin();
		require( _editEnd == false );

		_crowdSale = smartContract;
		_editEnd = true;
		return 	true;
	}

	/* 	+
	* 	This is function need for burn tokens crowdSale.
	* 	@param uint amount tokens for burn.
	*/
	function 	burn( uint amount ) public returns ( bool ) {
		require( _balanceOf[msg.sender] >= amount );
		require( msg.sender == _crowdSale );
		
		_balanceOf[msg.sender] -= amount;
		_totalSupply -= amount;

		Burn( msg.sender, amount );
		return true;
	}
	/* + */	
	function 	freezingTokens( uint amount )  public returns ( bool ) {
		assertAdmin();

		if ( _balanceOf[getAdmin()] <= amount ) {
			require( false );
		}
		_balanceOf[getAdmin()] -= amount;
		_freezingTokens = amount;

		FreezingTokens( getAdmin(), amount );
		return 	true;
	}
	/* + */
	function 	defrostingTokens() public returns ( bool ) {
		uint 	amount;

		assertAdmin();
		assertTime();

		amount = _freezingTokens;
		_freezingTokens = 0;
		_balanceOf[getAdmin()] += amount;

		DefrostingTokens( getAdmin(), amount );
		return 	true;
	}

	function   getTime() public constant returns( uint ) {
		return now;
	}
}
