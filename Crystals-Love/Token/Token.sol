pragma solidity ^0.4.18;

import 	"browser/ERC20.sol";
import 	"browser/Admin.sol";

contract Token is ERC20, Admin {
	uint 	public 	_freezingTokens;
	uint    public  _deadlineForToken; // Later named another name 

	event 	FreezingTokens(address admin, uint amount);
	event 	DefrostingTokens(address admin, uint amount);

	/* 
	*	"NameToken","SSS","43200","18", "5"
	*	construct for remix solidity
	*/ 
	function 	Token(string nameToken, string symbolToken, uint supply, uint8 decimals, uint time)
				ERC20(nameToken, symbolToken, supply, decimals) Admin(msg.sender) public {
		 _deadlineForToken = now + time * 1 minutes;
	}
	
	/* + */	
	function 	freezingTokens(uint amount)  public returns (bool) {
		assertAdmin();

		if (_balanceOf[getAdmin()] <= amount) {
			require(false);
		}
		_balanceOf[getAdmin()] = sub( _balanceOf[getAdmin()], amount );
		_freezingTokens = amount;

		FreezingTokens(getAdmin(), amount);
		return 	true;
	}

	/* - */
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
	/* - */
	function    getTime() public constant returns(uint) {
		return now;
	}
	/* - */
	function    assertTimeFrosing() view internal {
		if (now <= _deadlineForToken) {
			require(false);
		}
	}
}
