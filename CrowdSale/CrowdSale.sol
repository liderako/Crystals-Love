pragma solidity ^0.4.21;

import	"./WhiteList.sol";
import 	"./SafeMathSale.sol";

interface 	Token {
	function 	transfer(address _to, uint _value) external returns (bool success);
}

contract 	CrowdSale is AdminPanel {

	using SafeMathSale for uint;

	uint 	public	_amountRaised;
	bool 	public 	_saleClosed;
	bool 	public 	_saleSuccess;

	/*
	**   Constants
	*/
	//uint    public constant 	MIN_ETHER_RAISED = 600 * 1 ether;

	uint	public constant		_startSale;
	uint    public constant 	_deadLineSale;
	uint 	public constant		_rate = 7000;
	uint    public constant 	_softCap = 2 * 1 ether;
	uint    public constant 	_hardCap = 6 * 1 ether;
	Token 	public constant 	_tokenReward = Token( 0xa54fbd3339dc1a6082718852072b82dde3403865 );
	
	/*
	**   Balances ETH 
	*/
	mapping(address => uint) private _balanceOf;

	/*
	**   Events
	*/
	event 	DepositEther(address owner, uint amount);
	event 	TransferToken(address user, uint amount);
	event 	WithdrawEther(address owner, uint amount);
	event   GoalReachedSoftCap(uint amountRaised, bool saleSuccess);
	event  	GoalReachedHardCap(uint amountRaised, bool saleSuccess);

	// нужно протестировать
	function 	CrowdSale() AdminPanel(msg.sender) public {
		uint constant startSaleMinutes = 10;
		uint constant endSaleMinutes = 10;

		_startSale = now + (startSaleMinutes) * 1 minutes;
		_deadLineSale = now + (endSaleMinutes + startSaleMinutes) * 1 minutes;
		require(_startSale < _deadLineSale);
	}

	/*
	**	Fallback function for raising ether
	*/
	// нужно дописать
	// нужно протестировать
	function () external payable {
		uint 	amount;

		amount = msg.value;
		/* Validation data */
		require(getBalanceDepositEth(msg.sender) == 0);
		require(now >= _startSale && now <= _deadLineSale); /* check start and deadline of presale */
		require(_saleClosed == false); /* check if crowdsale is closed */
		assertRemain(amount);
		/*End  validation data */

		setBalanceDepositEth(msg.sender, amount);
		setTimeBeforeMoneyBack(msg.sender, 3)

		emit DepositEther(msg.sender, amount);
	}
	// нужно дописать
	// нужно протестировать
	function 	sendToken(address user) public {
		uint 	amount;

		amount = getBalanceDepositEth(user);

		assertModerator();
		assertNull(user);
		assertRemain(amount);
		require (amount > 0);

		_balanceOf[user] = _balanceOf[user].add(amount); // add for eth donates
		_amountRaised = _amountRaised.add(amount); // add for all sum
		setBalanceDepositEth() = 0;
		
		goalManagement(); // check for last payable

		_tokenReward.transfer(user, amount.mul(_rate));
		emit SendToken()
	}

	/*
	**   Function for check goal reaching
	*/
	// нужно протестировать
	function 	goalManagement() private {
		if (_amountRaised >= _hardCap) { // check current balance
			_saleClosed = true;
			_saleSuccess = true
			emit GoalReachedHardCap(_amountRaised, true);
		}
		else if (_amountRaised >= _softCap && _saleSuccess != true) {
			_saleSuccess = true;
			emit GoalReachedSoftCap(_amountRaised, true);
		}
	}
	
	/*
	**	Функция для вывода денег для тех пользователей которым было отказано в доступе,
	** 	или не был подвержден перевод токенов в течении трех дней.
	**	Вывод денег происходит из маппинга _balanceDepositEth;
	*/
	// нужно протестировать
	function 	withdrawEth() public {
		uint 	amount;

		amount = getBalanceDepositEth(msg.sender);
		setBalanceDepositEth(msg.sender, 0);
		require(amount != 0);
		require(now >= getTimeBeforeMoneyBack(msg.sender) || );

		msg.sender.transfer(amount);
		emit WithdrawEther(msg.sender, amount);
	}
	
	/*
	** Функция для вывода денег если исо не успешное
	** выводятся средства с мапинга balanceOF
	*/
	// нужно протестировать
	function    withdrawalMoneyBack() public {
		uint 	amount;

		require (_saleSuccess == false);
		require (_saleClosed == true);
		amount = _balanceOf[msg.sender];
		_balanceOf[msg.sender] = 0;
		_amountRaised = _amountRaised.sub(amount);
		msg.sender.transfer(amount);
		emit WithdrawEther(msg.sender, amount);
	}

	/*
	**	Function for withdrawal ether by admin
	**	if crowdsale is success
	*/
	// нужно протестировать
	function 	withdrawalAdmin() public {
		uint 	amount;

		assertAdmin();
		require (_saleClosed == false);
		require (_saleSuccess == false);

		amount = _amountRaised;
		_amountRaised = 0;
		msg.sender.transfer(amount);
		emit WithdrawEther(msg.sender, amount);
	}

	/*
	**	Function for close ICO if it isn't success
	*/
	function    closeSale() public {
		require(now >= _deadLineSale);	/* check Deadline of presale */
		require(_saleClosed == false);	/* check if crowdsale is closed */
		_saleClosed = true;
	}

	// нужно дописать
	function 	assertRemain(uint amount) pure private {
		uint 	remain = 0;

		require (true);
		
		// remain = MIN_ETHER_RAISED.sub(_amountRaised);
		// require(amount <= remain);
	}
}
