pragma solidity ^0.4.0;

contract Alea {
	uint public refferalSentAmount = 0;
	uint public potAmount = 0;
	uint public ticketsSold = 0;
	uint public nParticipants = 0;

	uint public winnerPercentaje = 80;
	uint public referralPercentaje = 5;

	uint256 public cratedTime;

	uint256 public timePerLottery = 60*60*24*14;


	uint public lastWinnerPotAmount;
	address public lastWinner;

	Participant[] public participants;
	address[] public players;

	uint public ticketPrice = 0.01 ether;

	address creator1 = 0x9D7067FEf1469feDdDbe52f6225f3341b7701acF; 
	address creator2 = 0xd32c259C7656864bb2798a743C7de595E717a4b3;
	
	event UserStatus(string _msg, address user, uint amount, uint256 time);

	struct Participant {
		address adr;
		uint tickets;
		address referral;
	}

	function Alea() public {
		cratedTime = block.timestamp;
		UserStatus('Loterry Created', msg.sender, 0, block.timestamp);
	}

	function buyTicket(uint amount) public payable {
		if(msg.value >= ticketPrice * amount && block.timestamp < (cratedTime + timePerLottery)) {
			addToArray(msg.sender, amount);
			ticketsSold += amount;
        	if(hasAccount(msg.sender, msg.value, amount) == false) {
        		address finalReferral = assignCreatorReferral();
        		nParticipants++;
            	participants.push(Participant({
                 adr: msg.sender,
               	 tickets: amount,
               	 referral: finalReferral
           		 }));
            	finalReferral.transfer(msg.value * referralPercentaje / 100);
            	UserStatus('Ticket Bought', msg.sender, msg.value, block.timestamp);
       	 	}
			potAmount = this.balance;
		} else {
			revert();
		}
	}

	function buyTicketReferral(address referral, uint amount) public payable {
		if(msg.value >= ticketPrice * amount && block.timestamp < (cratedTime + timePerLottery)) {
			addToArray(msg.sender, amount);
			ticketsSold += amount;
        	if(hasAccount(msg.sender, msg.value, amount) == false) {
        		nParticipants++;
            	participants.push(Participant({
                 adr: msg.sender,
               	 tickets: amount,
               	 referral: referral
           	 }));
            UserStatus('Ticket Bought', msg.sender, msg.value, block.timestamp);
			referral.transfer(msg.value * referralPercentaje / 100);
			refferalSentAmount = refferalSentAmount + (msg.value * referralPercentaje / 100);
       	 }
            potAmount = this.balance;
		} else {
			revert();
		}
	}

	function hasAccount(address _address, uint value, uint amount) private returns (bool){
			bool isParticipant = false;
			for(uint i = 0; i < participants.length; i++) {
            	if(participants[i].adr == _address) {
                	participants[i].tickets += amount;
                	isParticipant = true;
                	participants[i].referral.transfer(value * referralPercentaje / 100);
            	}
       		}
       	return isParticipant;
	}

	function assignCreatorReferral() private view returns (address) {
		if((block.timestamp % 2) == 0) {
        	return creator1;
        } else {
        	return creator2;

        } 
	}

	function addToArray(address _address, uint amount) private {
		for(uint i = 0; i < amount; i++) {
			players.push(_address);
		}
	}

	function random() private view returns (uint) {
		return uint(keccak256(block.difficulty, now, players));
	}

	function endLottery() public {
		if(block.timestamp > (cratedTime + timePerLottery)) {
			uint index =  random() % players.length;	
       		lastWinner = players[index];
       		players[index].transfer(potAmount * winnerPercentaje / 100);
			lastWinnerPotAmount = (potAmount * winnerPercentaje / 100);
			creator1.transfer(this.balance / 2);
			creator2.transfer(this.balance);
        	UserStatus('Loterry Ended, Winner:', lastWinner, lastWinnerPotAmount, block.timestamp);

		} else {
			revert();
		}
	}
}
