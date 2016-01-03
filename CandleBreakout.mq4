//+------------------------------------------------------------------+
//|                                               CandleBreakout.mq4 |
//|                       Copyright 2016, Norganna's AddOns Pty Ltd. |
//|                                          http://www.norganna.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Norganna's AddOns Pty Ltd."
#property link      "http://www.norganna.com"
#property version   "1.02"
#property strict
#property description "This indicator identifies channels and pricing"
#property description "points in your charts based off the teachings"
#property description "of Janna FX and her No signals, No indicators"
#property description "trading system. http://jannafx.com"
#property description "It comes with an (optional) companion EA which"
#property description "if enabled will allow you to place orders from"
#property description "the chart."

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   10

#property indicator_label1  "Max band"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Min band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCadetBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Buy"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_DASH
#property indicator_width3  1

#property indicator_label4  "Buy stop"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_DOT
#property indicator_width4  1

#property indicator_label5  "Buy profit"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
#property indicator_style5  STYLE_DASH
#property indicator_width5  1

#property indicator_label6  "Sell"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_DASH
#property indicator_width6  1

#property indicator_label7  "Sell stop"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrRed
#property indicator_style7  STYLE_DOT
#property indicator_width7  1

#property indicator_label8  "Sell profit"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrGreen
#property indicator_style8  STYLE_DASH
#property indicator_width8  1


#property indicator_label9  "Max extent"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrCadetBlue
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1

#property indicator_label10  "Min extent"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrCadetBlue
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1


string buttonName = "Candle focus";

input int inpPeriod = 20; // Channel period
input int inpDuration = 10; // Minimum event duration
input double inpBuy = 0.002; // Buy point
input double inpProfit = 0.001; // Profit amount
input double inpStop = 0.003; // Stop sell point
input double inpMaxSpread = 0.005; // Maximum spread for consideration
input double inpLots = 1.0; // Order size in lots

double         UpperBuffer[];
double         LowerBuffer[];
double         UpperExtBuffer[];
double         LowerExtBuffer[];
double         UpperBuyBuffer[];
double         LowerBuyBuffer[];
double         UpperProfitBuffer[];
double         LowerProfitBuffer[];
double         UpperStopBuffer[];
double         LowerStopBuffer[];


int OnInit() {
	SetIndexBuffer(0,UpperBuffer);
	SetIndexBuffer(1,LowerBuffer);
	SetIndexBuffer(8,UpperExtBuffer);
	SetIndexBuffer(9,LowerExtBuffer);

	SetIndexBuffer(2,UpperBuyBuffer);
	SetIndexBuffer(3,UpperStopBuffer);
	SetIndexBuffer(4,UpperProfitBuffer);

	SetIndexBuffer(5,LowerBuyBuffer);
	SetIndexBuffer(6,LowerStopBuffer);
	SetIndexBuffer(7,LowerProfitBuffer);

	makeBox("Backdrop", 5, 5, 115, 65);
	makeButton("Focus button", "Focus", 10, 10, 50, 20);
	makeButton("Place button", "Place", 65, 10, 50, 20);
	makeText("Buy text", "Buy", 5, 35, 110, 15);
	makeText("Sell text", "Sell", 5, 50, 110, 15);

	return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason) {
	clearDialog();
	removeObjects();
	removeLine("Extent");
	removeLine("Focus");
}

void removeObjects() {
	ObjectDelete("Focus button");
	ObjectDelete("Place button");
	ObjectDelete("Backdrop");
	ObjectDelete("Buy text");
	ObjectDelete("Sell text");
}

void removeLine(const string name) {
	ObjectDelete(name);
}

void drawLine(
		const string name,
		const int pos,
		const color lineColor = clrCadetBlue,
		const int lineStyle = STYLE_DASH,
		const int lineWidth = 1
) {
	removeLine(name);

	if (pos > 0) {
		ObjectCreate(name, OBJ_VLINE, 0, iTime(NULL, 0, pos), 0);
		ObjectSet(name, OBJPROP_STYLE, lineStyle);
		ObjectSet(name, OBJPROP_COLOR, lineColor);
		ObjectSet(name, OBJPROP_WIDTH, lineWidth);
		ObjectSet(name, OBJPROP_BACK, 1);
	}
}

void showDialog(
		const string type,
		const string title,
		const string line1,
		const string line2,
		const string line3,
		const string line4,
		const string line5,
		const string data1,
		const string data2,
		const string data3
) {
	makeBox("Dialog box", 125, 5, 220, 150);
	makeText("Dialog title", title, 130, 15, 200, 20, 12);
	makeText("Dialog line1", line1, 130, 35, 200, 15);
	makeText("Dialog line2", line2, 130, 50, 200, 15);
	makeText("Dialog line3", line3, 130, 65, 200, 15);
	makeText("Dialog line4", line4, 130, 80, 200, 15);
	makeText("Dialog line5", line5, 130, 95, 200, 15);
	makeButton("Dialog yes", "Yes", 140, 120, 50, 20);
	makeButton("Dialog no", "No", 200, 120, 50, 20);
	makeText("Dialog type", type, 0,0,0,0);
	makeText("Dialog data1", data1, 0,0,0,0);
	makeText("Dialog data2", data2, 0,0,0,0);
	makeText("Dialog data3", data3, 0,0,0,0);
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
	ObjectDelete("Dialog data1");
	ObjectDelete("Dialog data2");
	ObjectDelete("Dialog data3");
	ObjectDelete("Dialog type");
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


void makeButton(
		const string name,
		const string title,
		const int x,
		const int y,
		const int w,
		const int h
) {
	ObjectCreate(name, OBJ_BUTTON, 0, 0, 0);
	ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x + w);
	ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
	ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
	ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
	ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
	ObjectSetString(0, name, OBJPROP_TEXT, title);
	ObjectSetString(0, name, OBJPROP_FONT, "Arial");
	ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 12);
	ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
	ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrCadetBlue);
	ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrNONE);
	ObjectSetInteger(0, name, OBJPROP_BACK, false);
	ObjectSetInteger(0, name, OBJPROP_STATE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
	ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
	ObjectSetInteger(0, name, OBJPROP_ZORDER, 100);
}

bool isButtonPressed(
	const string name
) {
	return (ObjectGetInteger(0, name, OBJPROP_STATE) == true);
}

void setButtonPressed(
	const string name,
	const bool pressed = true
) {
	ObjectSetInteger(0, name, OBJPROP_STATE, pressed);
}

void makeText(
		const string name,
		const string title,
		const int x,
		const int y,
		const int w,
		const int h,
		const int size = 10,
		const color clr = clrWhite
) {
	ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
	ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x + w);
	ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
	ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
	ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
	ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
	ObjectSetInteger(0, name, OBJPROP_BACK, false);
	ObjectSetInteger(0, name, OBJPROP_STATE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
	ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
	ObjectSetText(name, title, size, "Arial", clr);
}

void setText(
		const string name,
		const string title,
		const int size = 10,
		const color clr = clrWhite
) {
	ObjectSetText(name, title, size, "Arial", clr);
}

void makeBox(
		const string name,
		const int x,
		const int y,
		const int w,
		const int h
) {
	ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
	ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x + w);
	ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
	ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
	ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
	ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
	ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrBlack);
	ObjectSetInteger(0, name, OBJPROP_STYLE, 0); 
	ObjectSetInteger(0, name, OBJPROP_WIDTH, 0); 
	ObjectSetInteger(0, name, OBJPROP_FILL, true);
	ObjectSetInteger(0, name, OBJPROP_BACK, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
	ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
}
   
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
	int i, s, pos, extent;
	double max, min, h, l, ch, cl, mmspread, cmin, cmax;

	extent = 0;
	cmin = 0;
	cmax = 0;
	h = 0;
	l = 0;
	ch = 0;
	cl = 0;

	int limit = rates_total - prev_calculated + inpPeriod * 2;

	if (limit > rates_total) {
		limit = rates_total;
	}

	for (i = 0; i < limit; i++) {
		s = i + inpPeriod;
		if (s > rates_total) {
			s = rates_total;
		}

		max = -1;
		min = -1;
		for (pos = i; pos < s; pos++) {
			if (open[pos] > close[pos]) {
				h = open[pos];
				l = close[pos];
			} else {
				l = open[pos];
				h = close[pos];
			}

			if (pos == i) {
				ch = h;
				cl = l;
			}

			if (max < 0 || h > max) {
				max = h;
			}
			if (min < 0 || l < min) {
				min = l;
			}
		}

		UpperBuffer[i] = max;
		LowerBuffer[i] = min;
		UpperExtBuffer[s - 1] = max;
		LowerExtBuffer[s - 1] = min;

		mmspread = max - min;
		if (mmspread > inpMaxSpread) {
			UpperBuyBuffer[i] = EMPTY_VALUE;
			LowerBuyBuffer[i] = EMPTY_VALUE;
			UpperProfitBuffer[i] = EMPTY_VALUE;
			LowerProfitBuffer[i] = EMPTY_VALUE;
			UpperStopBuffer[i] = EMPTY_VALUE;
			LowerStopBuffer[i] = EMPTY_VALUE;
		} else {
			UpperBuyBuffer[i] = max + inpBuy;
			LowerBuyBuffer[i] = min - inpBuy;
			UpperProfitBuffer[i] = max + inpBuy + inpProfit;
			LowerProfitBuffer[i] = min - inpBuy - inpProfit;
			UpperStopBuffer[i] = max - inpStop;
			LowerStopBuffer[i] = min + inpStop;
		}

		if (i == 0) {
			cmin = min;
			cmax = max;
		} else {
			if (i < inpPeriod) {
				UpperExtBuffer[i] = cmax;
				LowerExtBuffer[i] = cmin; 
			}

			if (extent == 0 && (cl < cmin || ch > cmax)) {
				extent = i;
			}
		}      
	}

	for (i = 0; i < rates_total - prev_calculated; i++) {
		if (UpperBuyBuffer[i] != EMPTY_VALUE) {
			pos = i + 1;
			int c = 0;
			while (pos < rates_total && UpperBuyBuffer[pos] != EMPTY_VALUE) {
				c++;
				pos++;
			}

			if (c < inpDuration) {
				for (pos = i; pos <= i + c; pos++) {
					UpperBuyBuffer[pos] = EMPTY_VALUE;
					LowerBuyBuffer[pos] = EMPTY_VALUE;
					UpperProfitBuffer[pos] = EMPTY_VALUE;
					LowerProfitBuffer[pos] = EMPTY_VALUE;
					UpperStopBuffer[pos] = EMPTY_VALUE;
					LowerStopBuffer[pos] = EMPTY_VALUE;
				}
			}

			i += c;
		}
	}


	drawLine("Extent", extent);
	updatePrices();

	return(rates_total);
}

datetime placeTime = NULL;
void updatePrices() {
	int pos = 0;
	if (isButtonPressed("Focus button")) {
		Print("PlaceTime ", placeTime);
		if (placeTime == NULL) {
			setText("Buy text", "Click on chart to");
			setText("Sell text", "set focus time.");
			return;
		} else {
			pos = iBarShift(NULL, 0, placeTime, false);
		}
	} else {
		placeTime = NULL;
	}

	if (pos == 0) {
		removeLine("Focus");
	} else {
		drawLine("Focus", pos, clrLightSteelBlue, STYLE_SOLID, 5);
	}

	double buy = UpperBuyBuffer[pos];
	double sell = LowerBuyBuffer[pos];

	if (buy == EMPTY_VALUE) {
		setText("Buy text", "No buy");
		setText("Sell text", "No sell");
	} else {
		setText("Buy text", "Buy at " + DoubleToString(buy, Digits));
		setText("Sell text", "Sell at " + DoubleToString(sell, Digits));
	}
}

void placeOrders() {
	int pos = 0;
	if (isButtonPressed("Focus button")) {
		if (placeTime == NULL) {
			Alert("Please click on the chart to finish focus before placing orders");
			setButtonPressed("Place button", false);
			return;
		} else {
			pos = iBarShift(NULL, 0, placeTime, false);
		}
	}

	double buy = NormalizeDouble(UpperBuyBuffer[pos], Digits);
	double buyTake = NormalizeDouble(UpperProfitBuffer[pos], Digits);
	double buyStop = NormalizeDouble(UpperStopBuffer[pos], Digits);
	double sell = NormalizeDouble(LowerBuyBuffer[pos], Digits);
	double sellTake = NormalizeDouble(LowerProfitBuffer[pos], Digits);
	double sellStop = NormalizeDouble(LowerStopBuffer[pos], Digits);

	if (buy == EMPTY_VALUE) {
		Alert("There is no price at current time");
		setButtonPressed("Place button", false);
		return;
	}

	string symbol = Symbol();
	double freeMargin = AccountFreeMargin();
	double minStopDist = MarketInfo(symbol, MODE_STOPLEVEL);
	double minLot = MarketInfo(symbol, MODE_MINLOT);
	double lotStep = MarketInfo(symbol, MODE_LOTSTEP);
	double lotPrice = MarketInfo(symbol, MODE_LOTSIZE);
	double oneLotReq = MarketInfo(symbol, MODE_MARGINREQUIRED);
	double oneLotMaint = MarketInfo(symbol, MODE_MARGINMAINTENANCE);

	double lots = inpLots;
	if (lots < minLot) {
		lots = minLot;
	} else {
		lots = MathFloor( (lots - minLot) / lotStep ) * lotStep + minLot;
	}

//	Print("Symbol ", symbol, ", minStopDist ", minStopDist, ", minLot ", minLot, ", lotStep ", lotStep, ", lotPrice ", lotPrice, ", oneLotReq ", oneLotReq, ", oneLotMaint ", oneLotMaint);
//	Print("Digits ", Digits, ", ask ", Ask, ", point ", Point, ", freeMargin = ", freeMargin);
//	Print("Buy ", order, " lots at ", buy, ", TP ", buyTake, ", SL ", buyStop);
//	Print("Sell ", order, " lots at ", sell, ", TP ", sellTake, ", SL ", sellStop);

	showDialog("order",
		"Place order?",
		"Pending order for " + (string)lots + " lot" + (lots == 1 ? "" : "s"),
		" - Buy/Stop at " + DoubleToString(buy, Digits),
		"   T/P " + DoubleToString(buyTake, Digits) + ", S/L " + DoubleToString(buyStop, Digits),
		" - Sell/Stop at " + DoubleToString(sell, Digits),
		"   T/P " + DoubleToString(sellTake, Digits) + ", S/L " + DoubleToString(sellStop, Digits),
		StringConcatenate("cbOrder|", symbol, "|", DoubleToString(lots)),
		StringConcatenate(DoubleToString(buy), "|", DoubleToString(buyTake), "|", DoubleToString(buyStop)),
		StringConcatenate(DoubleToString(sell), "|", DoubleToString(sellTake), "|", DoubleToString(sellStop))
	);
}

bool ignNextClick = false;
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
) {
	if (id == CHARTEVENT_OBJECT_CLICK) {
		if (sparam == "Focus button") {
			ignNextClick = true;
			updatePrices();
		}
		if (sparam == "Place button") {
			if (isButtonPressed(sparam)) {
				placeOrders();
			} else {
				clearDialog();
				setButtonPressed("Place button", false);
			}
		}
		if (sparam == "Dialog no") {
			clearDialog();
			setButtonPressed("Place button", false);
		}
	} else if (id == CHARTEVENT_CLICK && isButtonPressed("Focus button") && placeTime == NULL) {
		if (ignNextClick) {
			ignNextClick = false;
			return;
		}

		int      x      = (int)lparam;
		int      y      = (int)dparam;
		datetime dt     = 0;
		double   price  = 0;
		int      window = 0;

		if (ChartXYToTimePrice(0, x, y, window, dt, price)) {
			placeTime = dt;
			updatePrices();
		}
	}
}
