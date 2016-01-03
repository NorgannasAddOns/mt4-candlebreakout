//+------------------------------------------------------------------+
//|                                              CandleBreakdown.mq4 |
//|                        Copyright 2016, Norganna's AddOns Pty Ltd |
//|                                         https://www.norganna.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Norganna's AddOns Pty Ltd"
#property link      "https://www.norganna.com"
#property version   "1.00"
#property strict

struct Order {
	string symbol;
	double lots;
	double buy;
	double buyTake;
	double buyStop;
	double sell;
	double sellTake;
	double sellStop;
};
Order order;

void unserializeOrder(string data) {
	Print("Unserialize ", data);

	string result[];
	ushort sep = StringGetCharacter("|", 0);
	StringSplit(data, sep, result);

	if (result[0] != "cbOrder") {
		order.symbol = "";
		return;
	}

	order.symbol = result[1];
	order.lots = StringToDouble(result[2]);
	order.buy = StringToDouble(result[3]);
	order.buyTake = StringToDouble(result[4]);
	order.buyStop = StringToDouble(result[5]);
	order.sell = StringToDouble(result[6]);
	order.sellTake = StringToDouble(result[7]);
	order.sellStop = StringToDouble(result[8]);
}

void clearDialog() {
	ObjectDelete("Dialog box");
	ObjectDelete("Dialog title");
	ObjectDelete("Dialog line1");
	ObjectDelete("Dialog line2");
	ObjectDelete("Dialog line3");
	ObjectDelete("Dialog line4");
	ObjectDelete("Dialog line5");
	ObjectDelete("Dialog yes");
	ObjectDelete("Dialog no");
	ObjectDelete("Dialog type");
	ObjectDelete("Dialog data1");
	ObjectDelete("Dialog data2");
	ObjectDelete("Dialog data3");
}

string getDialogType() {
	return ObjectGetString(0, "Dialog type", OBJPROP_TEXT);
}

string getDialogData() {
	string d1 = ObjectGetString(0, "Dialog data1", OBJPROP_TEXT);
	string d2 = ObjectGetString(0, "Dialog data2", OBJPROP_TEXT);
	string d3 = ObjectGetString(0, "Dialog data3", OBJPROP_TEXT);
	return StringConcatenate(d1, "|", d2, "|", d3);
}


int OnInit() {
	return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
}

void OnTick() {
}

void OnChartEvent(
		const int id,
		const long &lparam,
		const double &dparam,
		const string &sparam
) {
	if (id == CHARTEVENT_OBJECT_CLICK) {
		if (sparam == "Dialog yes" && getDialogType() == "order") {
			executeOrders();
			clearDialog();
		}
	}
}

void setButtonPressed(
	const string name,
	const bool pressed = true
) {
	ObjectSetInteger(0, name, OBJPROP_STATE, pressed);
}

void executeOrders() {
	int err = 0;
	int sellTicket = 0;

	unserializeOrder(getDialogData());

	if (order.symbol == "") {
		Alert("Unable to parse order details");
		return;
	}

	int buyTicket = OrderSend(
			order.symbol, OP_BUYSTOP,
			order.lots, order.buy, 0,
			order.buyStop, order.buyTake,
			"CandleBreakout", 0, 0,
			clrBlue
	);

	if (buyTicket > 0) {
		sellTicket = OrderSend(
				order.symbol, OP_SELLSTOP,
				order.lots, order.sell, 0,
				order.sellStop, order.sellTake,
				"CandleBreakout", 0, 0,
				clrRed
		);

		if (sellTicket <= 0) {
			err = GetLastError();
		}

	} else {
		err = GetLastError();
	}

	switch (err) {
		case 0:
			Alert("Trades entered successfully:\n  Buy ticket #" + (string)buyTicket + "\n  Sell ticket #" + (string)sellTicket);
			break;

		case ERR_TRADE_NOT_ALLOWED:
			Alert("Trade is not allowed.\nHave you enabled auto trading button?");
			break;

		case 129:
			Alert("Invalid price, please try again.");
			RefreshRates();
			break;

		case 135:
			Alert("The price has changed, please try again.");
			RefreshRates();
			break;

		case 146:
			Alert("Trading subsystem is busy, please try again.");
			RefreshRates();
			break;

		case 2:
			Alert("Common error.");
			break;

		case 5:
			Alert("Outdated version of the client terminal.");
			break;

		case 64:
			Alert("The account is blocked.");
			break;

		case 133:
			Alert("Trading fobidden");
			break;

		default:
			Alert("Unknown error occurred:", err);
			break;
	}

	setButtonPressed("Place button", false);
}

