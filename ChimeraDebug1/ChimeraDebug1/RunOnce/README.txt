This test verifies:

X	1.	CAN
X	 a.	Dedicated HS CAN : CAN1
X	 b.	Multiplexed CAN: CAN2
+	  i.	Hi Speed
+	  ii.	Low Speed
X	   1.	Can_error line
+	  iii.	One Wire
X	   1.	High Voltage Wakeup
X	   2.	C1w wire
X	  iv.	Aux Can transceiver
X	 c.	Voltage monitoring
X	 d.	Errors handled / communicated
X	2.	UART Busses
X	 a.	SingleWire1 (primarily RevComm )
X	  i.	Fixed thresholding
X	  ii.	Auto thresholding
X	  iii.	Pullup selection
X	  iv.	Interaction with Reverse Line
X	 b.	SingleWire2 (primarily LIN )
X	  i.	Fixed thresholding
X	  ii.	Auto Thresholding
X	 c.	RS422
X	 d.	RS485
X	 e.	RS232
X	  i.	Hardware flow control
X	 f.	SDL  -not really uart but uses same pins
X	 g.	Muxing UART1/2 correctly
X	3.	Power Supplies
X	 a.	On board 5/3_3/ unreg shutoff
X	 b.	Reverse
X	  i.	On/Off/open
X	 c.	Ignition
X	 d.	Battery
X	 e.	Cal 1_2v reference
X	4.	Aux I/O
X	 a.	Switches/LEDs
X	 b.	Open Collectors
X	 c.	8bit PIO
X	 d.	GP ADCs
X	5.	I2C
X	6.	SPI
X	7.	Dallas
X	8.	Periodic events
X	9.	Configuration Persistence?
X	10.	Sustained communication at high bus utilization
X	11.	Multiple simultaneous comms