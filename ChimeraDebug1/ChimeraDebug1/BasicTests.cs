using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections.Specialized;
using System.Windows.Forms;
using System.IO;
using System.Timers;








namespace ChimeraDebug1
{
    //dynamic lua = new DynamicLua.DynamicLua();
    //Chimera = new DevComm(@"C:\Users\josh.holovka\source\repos\ChimeraDebug1\ChimeraDebug1\CommandSets\ChimeraTester.cmdset", @"C:\DeviceCommService");
    //DUTDC = new DevComm(@"C:\Users\josh.holovka\source\repos\ChimeraDebug1\ChimeraDebug1\CommandSets\ChimeraTester.cmdset", @"C:\DeviceCommService");


    
       

    class BasicTests
    {
        private DevComm Chimera = new DevComm();
        private DevComm DUTDC = new DevComm();
        private DevComm[] DUTlin = new DevComm[5];

        
        Boolean RS232trans = false;
        Boolean RS232recep = false;
        Boolean RS485trans = false;
        Boolean RS485recep = false;
        Boolean RS422Trans = false;

        
        private int onewirechannel = 1;
        private StringDictionary settings = new StringDictionary();
        private StringDictionary DUTsettings = new StringDictionary();
     

        public Form1 MyForm;
        public ledpopup popup;

        Boolean AUXIO = false;
        Boolean DALLAS=false;
        Boolean SINGLEWIRE1 = false;
        Boolean SINGLEWIRE2 = false;
        Boolean UART = false;
        Boolean HIGHSPEEDCAN = false;
        Boolean MULTICAN = false;
        Boolean VOLTAGEIO = false;
        Boolean SIGNALCON = false;
        Boolean I2C = false;
        
         
       
        public BasicTests(Form1 form)
        {
           this.MyForm = form;
        }
        String logdata;
        public void echo(string text)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(DateTime.Now.ToString("HH:mm:ss ").PadRight(15));
            
            this.MyForm.log.AppendText(sb +text + "\r\n");
            logdata += sb.ToString() + text + "\r\n";
            
        }
        public void clearlog()
        {
            logdata = " ";
        }
        public string getlog()
        {
            return logdata;
        }
        public Boolean getAUIXO()
        {
            return AUXIO;
        }
        public Boolean getDallas()
        {
            return DALLAS;
        }
        public Boolean getSINGLEWIRE1()
        {
            return SINGLEWIRE1;
        }
        public Boolean getSINGLEWIRE2()
        {
            return SINGLEWIRE2;
        }
        public Boolean getUART()
        {
            return UART;
        }
        public Boolean getHIGHSPEEDCAN()
        {
            return HIGHSPEEDCAN;
        }
        public Boolean getMUlTICAN()
        {
            return MULTICAN;
        }
        public Boolean getVOLTAGEIO()
        {
            return VOLTAGEIO;
        }
        public Boolean getSIGNALCON()
        {
            return SIGNALCON;
        }
        public Boolean getI2C()
        {
            return I2C;
        }
        //******************************************************************************************Singlewire 1 Linn Test****************************************************************************************************

        public void pullUpDownTest()
        {
            
              Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            echo("**********Starting Singlewire 1 Test**********");
            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("LinPort", "LIN1");
            settings.Add("PullupSelection", "Open");
            Chimera.Initialize("ChimeraLin", settings);

            int Rdivide = 8442;  //10K in parallel with 54.2k (44.2K + 10K) for ADC read from chimera schematic
            double Vunreg = 14.86; //measured voltage for Vunreg
            double VdivideGain = 5.42; // gain from ADC1WIRE1 on micro to 1WIRE1 from J6 Connector due to voltage divider
            double ADCGain = 0.97073; //ADC Gain and Offset are to make up for an uncalibrated ADC on the chimera for closer accuracy
            double ADCoffset = 144.16;
            double tolerance = 0.10;  //desired tolerance for calculated resistor values

            String errorMessage = " ";
            Boolean Tolcheck = true;
            double[] Voltage = new double[5];

            String[] PullUpTable = { "Open", "1.5k", "2.2k", "6.8k", "10k" };
            double[] ResistorValues = { 0, 1.5, 2.2, 6.8, 10 };

            OrderedDictionary openCollect = new OrderedDictionary();
            openCollect.Add("Value", "0x01");
            openCollect.Add("Mask", "0x0F");
            Chimera.Write("OpenCollectors", openCollect);
            System.Diagnostics.Debug.WriteLine("DUT 1Wire disconnected from tester 1Wire1");

            //Using tester GPIO RE(0,1,2) to select DUT 1wire1 to connect to 10K pulldown
            OrderedDictionary gpioVal = new OrderedDictionary();
            gpioVal.Add("Value", "0x06");
            gpioVal.Add("Mask", "0xFF");
            gpioVal.Add("Direction", "0x00");
            Chimera.Write("GPIO", gpioVal);
            System.Diagnostics.Debug.WriteLine("10K pulldown resistor connected to DUT 1Wire1");
            echo("10K pulldown resistor connected to DUT 1Wire1");
            
            // Tester table for GPIO for selecting pulldown resistors

            //Write the following values using the tester chimera GPIO
            //to select the following resistor on the given line. The
            //pulldown resistors are connected to a mux and selected
            //by the tester GPIO REout pins.


            //          Write Wire
            //          value Selection       Resistance
            //----------------------------------------------

            //          0x00        none none

            //          0x04        1Wire 1         1k

            //          0x06        1Wire 1         10k

            //          0x07        1Wire 2         1k

            //          0x05        1Wire 2         10k

            //loop to cycle through all the DUT pullup resistors



            //initalize DUT connection with different pullup each loop

            echo("Cycling through Pulldown Resistors 1k, 10k for 1 wire1 and 1 wire 2");

            for (int i = 0; i < 5; i++)
            {
               // DUTDC.ShutDown();
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTsettings.Clear();
                DUTsettings.Add("IP", "10.1.1.2");
                DUTsettings.Add("LinPort", "LIN1");
                DUTsettings.Add("PullupSelection", PullUpTable[i]);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                System.Diagnostics.Debug.WriteLine("Current resistor picked " + PullUpTable[i]);
                echo("Current resistor picked " + PullUpTable[i]);
                

                if (PullUpTable[i] == "Open")
                {
                    System.Diagnostics.Debug.WriteLine("Pullup Selected: " + PullUpTable[i]);
                    echo("Pullup Selected: " + PullUpTable[i]);
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("Pullup Selected: " + PullUpTable[i]);
                    echo("Pullup Selected: " + PullUpTable[i]);
                }
                //reading ADC1WIRE1 from DUT Mirco
                //Converting reading value 
                OrderedDictionary reading = new OrderedDictionary();
                reading = DUTDC.Read("Analog");
                System.Diagnostics.Debug.WriteLine("REading Value: " + reading["SingleWire1"]);
                string singleWire = reading["SingleWire1"].ToString();

                System.Diagnostics.Debug.WriteLine("Single Wire value: " + singleWire);
                echo("SingleWire value: " + singleWire);
                

                double val = double.Parse(singleWire);
                val = val * VdivideGain;
                Voltage[i] = val;

                //Voltage Divider R1= R2* (Vin-Vout)/Vout
                double Rpullup = (((((Rdivide * (Vunreg - Voltage[i])) / Voltage[i]) * ADCGain) - ADCoffset) * .001);

                //Printing INFO
                if (PullUpTable[i] == "Open")
                {
                    System.Diagnostics.Debug.WriteLine(" SingleWire1 Voltage: " + Voltage[i] + "v");
                    echo("SingleWire1 Voltage: " + Voltage[i] +"v");
                    
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine(" SingleWire1 Voltage: " + Voltage[i] + "v");
                    echo(" SingleWire1 Voltage: " + Voltage[i] + "v");
                    System.Diagnostics.Debug.WriteLine("Calculated Resistance: " + Rpullup + "k");
                    echo("Calculated Resistance: " + Rpullup + "k");
                }
                //checking calculated resistor value is within +/-x % of expected
                //calculated value will not be perfect since ADC is not calibrated with each loop
                double low = ResistorValues[i] - (ResistorValues[i] * tolerance);
                double high = ResistorValues[i] + (ResistorValues[i] * tolerance);

                //any check failing puts final check false
                //keeps track of error message in case of fail

                if ((Rpullup >= low) && (Rpullup <= high))
                {
                    Tolcheck = true;
                }
                else if (Voltage[i] == 0)
                {
                    Tolcheck = true;
                }
                else
                {
                    Tolcheck = false;
                }
                if (!Tolcheck)
                {
                    errorMessage = errorMessage + PullUpTable[i] + " pullup selection out of " + (tolerance * 100) + "% tolerance range! check calculated resistor value!\n";
                    echo(PullUpTable[i] + " pullup selection out of " + (tolerance * 100) + "% tolerance range! check calculated resistor value!");
                }

            }
            //Resetting open collectors and GPIO
            openCollect.Clear();
            //openCollect.Add("Value", Convert.ToByte(0x00));
            //openCollect.Add("Mask", Convert.ToByte(0x0F));
            //Chimera.Write("OpenCollectors", openCollect);

            //gpioVal.Clear();
            //gpioVal.Add("Value", Convert.ToByte(0x00));
            //gpioVal.Add("Mask", Convert.ToByte(0xFF));
            //gpioVal.Add("Direction", Convert.ToByte(0x00));
            //Chimera.Write("GPIO", gpioVal);

            //Resetting open collectors and GPIO
            echo("Resetting Open Collectors and GPIO");
            openCollect.Add("Value", "0x00");
            openCollect.Add("Mask", "0x0F");
            Chimera.Write("OpenCollectors", openCollect);


            //Using tester GPIO RE(0,1,2) to select DUT 1wire1 to connect to 10K pulldown
            gpioVal.Clear();
            gpioVal.Add("Value", "0x00");
            gpioVal.Add("Mask", "0xFF");
            gpioVal.Add("Direction", "0x00");
            Chimera.Write("GPIO", gpioVal);
            echo(" ");
           // Chimera.ShutDown();
            //DUTDC.ShutDown();
        }
        //Check Revcomm

        //*************************************************************************************Revcomm Singlewire1 Lin Test***************************************************************************************

        public void singleWire1Test()
        {
            Boolean trans = false;
            Boolean recep = false;

            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            //settings.Add("Channel", "1");
            settings.Add("LinPort", "LIN1");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            //DUTsettings.Add("Channel", "1");
            DUTsettings.Add("LinPort", "LIN1");

            Chimera.Initialize("ChimeraLin", settings);
            DUTDC.Initialize("ChimeraLin", DUTsettings);

            System.Diagnostics.Debug.WriteLine("NOTE: See README.doc for the following error");
            System.Diagnostics.Debug.WriteLine("Error : Message was empty!");

            OrderedDictionary collect = new OrderedDictionary();

            //Switch on OCC3 to trun on relay and short 1w1 between tester and DUT
            collect.Add("Value", "0x04");
            collect.Add("Mask", "0x0F");


            Chimera.Write("OpenCollectors", collect);
            OrderedDictionary data = new OrderedDictionary();
            OrderedDictionary result = new OrderedDictionary();
            
            
            //while (!test && i < 20)
            //{
            //    try
            //    {
            //checking transmission
            data.Clear();
            data.Add("Data", "0xAA");
            //send data
            string answer1 = " ";
            string answer2 = " ";
            string answer3 = " ";
            string answer4 = " ";

            try
            {
                echo("Checking Singlewire 1 Transmission...");
                echo("Sending Data: 170 187 204 238");
                DUTDC.Do("SendData", data);
                System.Threading.Thread.Sleep(50);

                //recieve data
                Chimera.Do("ReadData", out result);
                answer1 = result["Data"].ToString();
              

                Chimera.ShutDown();
                DUTDC.ShutDown();
                 DevComm Chimera1 = new DevComm();
                 DevComm DUTDC1 = new DevComm();

                 Chimera1 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC1 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera1.Initialize("ChimeraLin", settings);
                DUTDC1.Initialize("ChimeraLin", DUTsettings);
                System.Threading.Thread.Sleep(50);
                Chimera1.Write("OpenCollectors", collect);

                data.Clear();
                result.Clear();

                data.Add("Data", "0xBB");
                //send data
                DUTDC1.Do("SendData", data);
                //recieve data
                Chimera1.Do("ReadData", out result);
                 answer2 = result["Data"].ToString();

                data.Clear(); 
                result.Clear();
                Chimera1.Dispose();
                DUTDC1.Dispose();


                 DevComm Chimera2 = new DevComm();
                 DevComm DUTDC2 = new DevComm();

                Chimera2 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC2 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera2.Initialize("ChimeraLin", settings);
                DUTDC2.Initialize("ChimeraLin", DUTsettings);              
                Chimera2.Write("OpenCollectors", collect);

                data.Add("Data", "0xCC");
                //send data
                DUTDC2.Do("SendData", data);
                //recieve data
                Chimera2.Do("ReadData", out result);
                 answer3 = result["Data"].ToString();

                data.Clear();
                result.Clear();

                Chimera2.Dispose();
                DUTDC2.Dispose();


                 DevComm Chimera3 = new DevComm();
                 DevComm DUTDC3 = new DevComm();
        Chimera3 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC3 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera3.Initialize("ChimeraLin", settings);
                DUTDC3.Initialize("ChimeraLin", DUTsettings);               
                Chimera3.Write("OpenCollectors", collect);

                data.Add("Data", "0xEE");
                //send data
                DUTDC3.Do("SendData", data);
                //recieve data
                Chimera3.Do("ReadData", out result);
                 answer4 = result["Data"].ToString();
                Chimera3.Dispose();
                DUTDC3.Dispose();

                echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3+" "+ answer4);
            }catch(Exception ex)
            {
                echo("Error during singlewire 1 transmission test");
                echo(" ");
                echo(ex.ToString());
                this.MyForm.SingleWire1.BackColor = Color.Red;
                this.MyForm.SingleWire1.Refresh();

            }
            
            if (answer1=="170" && answer2=="187" && answer3=="204" && answer4 == "238")
            {
                echo("Singlewire 1 Transmission Test Passed!!!");
                trans = true;
            }
            

            //Checking Reception


           

             DevComm Chimera4 = new DevComm();
             DevComm DUTDC4 = new DevComm();

            Chimera4 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
            DUTDC4 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
            Chimera4.Initialize("ChimeraLin", settings);
            DUTDC4.Initialize("ChimeraLin", DUTsettings);
            Chimera4.Write("OpenCollectors", collect);

            System.Diagnostics.Debug.WriteLine("Checking Reception");
            echo("Checking Singlewire 1 Reception...");
            

            try
            {
                
                
                echo("Sending Data: 238 204 187 170");
                //checking Reception
                result.Clear();
                data.Clear();
                data.Add("Data", "0xEE");
                //send data
                Chimera4.Do("SendData", data);
                //recieve data
                DUTDC4.Do("ReadData", out result);
                answer1 = result["Data"].ToString();

                Chimera4.Dispose();
                DUTDC4.Dispose();

                DevComm Chimera5 = new DevComm();
                DevComm DUTDC5 = new DevComm();

                Chimera5 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC5 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera5.Initialize("ChimeraLin", settings);
                DUTDC5.Initialize("ChimeraLin", DUTsettings);
                Chimera5.Write("OpenCollectors", collect);

                result.Clear();
                data.Clear();
                data.Add("Data", "0xCC");
                //send data
                Chimera5.Do("SendData", data);
                //recieve data
                DUTDC5.Do("ReadData", out result);
                answer2 = result["Data"].ToString();

                Chimera5.Dispose();
                DUTDC5.Dispose();

                DevComm Chimera6 = new DevComm();
                DevComm DUTDC6 = new DevComm();

                Chimera6 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC6 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera6.Initialize("ChimeraLin", settings);
                DUTDC6.Initialize("ChimeraLin", DUTsettings);
                Chimera6.Write("OpenCollectors", collect);

                result.Clear();
                data.Clear();
                data.Add("Data", "0xBB");
                //send data
                Chimera6.Do("SendData", data);
                //recieve data
                DUTDC6.Do("ReadData", out result);
                answer3 = result["Data"].ToString();

                Chimera6.Dispose();
                DUTDC6.Dispose();

                DevComm Chimera7 = new DevComm();
                DevComm DUTDC7 = new DevComm();

                Chimera7 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC7 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera7.Initialize("ChimeraLin", settings);
                DUTDC7.Initialize("ChimeraLin", DUTsettings);
                Chimera7.Write("OpenCollectors", collect);

                result.Clear();
                data.Clear();
                data.Add("Data", "0xAA");
                //send data
                Chimera7.Do("SendData", data);
                //recieve data
                DUTDC7.Do("ReadData", out result);
                answer4 = result["Data"].ToString();

                collect.Clear();
                echo(" ");
                // Switch off all open collectors
                collect.Add("Value", "0x00");
                collect.Add("Mask", "0x0F");
                Chimera7.Write("OpenCollectors", collect);
                echo(" ");
                Chimera7.Dispose();
                DUTDC7.Dispose();


                System.Diagnostics.Debug.WriteLine("Revcomm Singlewire test data: " + answer1 + " " + answer2 + " " + answer3 + " " + answer4);
                echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3 + " " + answer4);
                
                if (answer1=="238" && answer2=="204" && answer3=="187" && answer4 == "170")
                {
                    echo("Singlewire 1 Reception Tests Passed!!!");
                    recep = true;
                }
                if(trans==true && recep== true)
                {
                    this.MyForm.SingleWire1.BackColor = Color.Green;
                    this.MyForm.SingleWire1.Refresh();
                    echo("**********Singlewire 1 Tests Passed **********");
                    SINGLEWIRE1 = true;
                }
             
            }
            catch(Exception ex)
            {
                echo("Error during Singlewire 1 Reception Test");
                echo(" ");
                echo(ex.ToString());
                this.MyForm.SingleWire1.BackColor = Color.Red;
                this.MyForm.SingleWire1.Refresh();
                SINGLEWIRE1 = false;
            }
           

        }


        //******************************************************************************************Single Wire 2**************************************************************************************


        public void singleWire2Test()
        {

           

            // Checking Lin Transmission

            //Changes from default occur here
            // tester using 1wire1(LIN1)
            // DUT using 1wire2 (LIN2)

            Boolean trans = false;
            Boolean recep = false;
            echo("**********Starting Singlewire 2 Test**********");
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            //settings.Add("Channel", "1");
            settings.Add("LinPort", "LIN1");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            //DUTsettings.Add("Channel", "1");
            DUTsettings.Add("LinPort", "LIN2");

            Chimera.Initialize("ChimeraLin", settings);
            DUTDC.Initialize("ChimeraLin", DUTsettings);

            System.Diagnostics.Debug.WriteLine("NOTE: See README.doc for the following error");
            System.Diagnostics.Debug.WriteLine("Error : Message was empty!");

            OrderedDictionary collect = new OrderedDictionary();

            //Switch on OC1,OC2 to turn on relay and short 1w2 between tester and DUT
            collect.Add("Value", "0x03");
            collect.Add("Mask", "0x0F");


            Chimera.Write("OpenCollectors", collect);
            OrderedDictionary data = new OrderedDictionary();
            OrderedDictionary result = new OrderedDictionary();
            
            
           
            //checking transmission
            data.Clear();
            data.Add("Data", "0xAA");
            //send data
            string answer1 = " ";
            string answer2 = " ";
            string answer3 = " ";
            string answer4 = " ";

            try
            {
                
                echo("Checking Singlewire 2 Transmission...");
                echo("Sending Data: 170 187 204 238");
                DUTDC.Do("SendData", data);


                //recieve data
                Chimera.Do("ReadData", out result);
                answer1 = result["Data"].ToString();


                Chimera.ShutDown();
                DUTDC.ShutDown();

                DevComm Chimera1 = new DevComm();
                DevComm DUTDC1 = new DevComm();

                Chimera1 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC1 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera1.Initialize("ChimeraLin", settings);
                DUTDC1.Initialize("ChimeraLin", DUTsettings);
                Chimera1.Write("OpenCollectors", collect);

                data.Clear();
                result.Clear();

                data.Add("Data", "0xBB");
                //send data
                DUTDC1.Do("SendData", data);
                //recieve data
                Chimera1.Do("ReadData", out result);
                answer2 = result["Data"].ToString();

                data.Clear();
                result.Clear();
                Chimera1.Dispose();
                DUTDC1.Dispose();

                DevComm Chimera2 = new DevComm();
                DevComm DUTDC2 = new DevComm();

                Chimera2 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC2 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");

                Chimera2.Initialize("ChimeraLin", settings);
                DUTDC2.Initialize("ChimeraLin", DUTsettings);
                Chimera2.Write("OpenCollectors", collect);

                data.Add("Data", "0xCC");
                //send data
                DUTDC2.Do("SendData", data);
                //recieve data
                Chimera2.Do("ReadData", out result);
                answer3 = result["Data"].ToString();

                data.Clear();
                result.Clear();

                Chimera2.Dispose();
                DUTDC2.Dispose();

                DevComm Chimera3 = new DevComm();
                DevComm DUTDC3 = new DevComm();

                Chimera3 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC3 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");

                Chimera3.Initialize("ChimeraLin", settings);
                DUTDC3.Initialize("ChimeraLin", DUTsettings);
                Chimera3.Write("OpenCollectors", collect);

                data.Add("Data", "0xEE");
                //send data
                DUTDC3.Do("SendData", data);
                //recieve data
                Chimera3.Do("ReadData", out result);
                answer4 = result["Data"].ToString();
                Chimera3.Dispose();
                DUTDC3.Dispose();

                echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3 + " " + answer4);
            }
            catch (Exception ex)
            {
                echo("Error during singlewire 2 transmission test");
                echo(" ");
                echo(ex.ToString());
                this.MyForm.SingleWire2.BackColor = Color.Red;
                this.MyForm.SingleWire2.Refresh();
            }

            if (answer1 == "170" && answer2 == "187" && answer3 == "204" && answer4 == "238")
            {
                
                echo("Singlewire 2 Transmission Test Passed!!!");
                trans = true;
            }


            //Checking Reception

            echo(" ");

            DevComm Chimera4 = new DevComm();
            DevComm DUTDC4 = new DevComm();

            Chimera4 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
            DUTDC4 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
            Chimera4.Initialize("ChimeraLin", settings);
            DUTDC4.Initialize("ChimeraLin", DUTsettings);
            Chimera4.Write("OpenCollectors", collect);







            System.Diagnostics.Debug.WriteLine("Checking Reception");
            echo("Checking Singlewire 2 Reception...");


            try
            {
                
                
                
                echo("Sending Data: 238 204 187 170");
                //checking Reception
                result.Clear();
                data.Clear();
                data.Add("Data", "0xEE");
                //send data
                Chimera4.Do("SendData", data);
                //recieve data
                DUTDC4.Do("ReadData", out result);
                answer1 = result["Data"].ToString();

                Chimera4.Dispose();
                DUTDC4.Dispose();

                DevComm Chimera5 = new DevComm();
                DevComm DUTDC5 = new DevComm();

                Chimera5 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC5 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera5.Initialize("ChimeraLin", settings);
                DUTDC5.Initialize("ChimeraLin", DUTsettings);
                Chimera5.Write("OpenCollectors", collect);

                result.Clear();
                data.Clear();
                data.Add("Data", "0xCC");
                //send data
                Chimera5.Do("SendData", data);
                //recieve data
                DUTDC5.Do("ReadData", out result);
                answer2 = result["Data"].ToString();

                Chimera5.Dispose();
                DUTDC5.Dispose();

                DevComm Chimera6 = new DevComm();
                DevComm DUTDC6 = new DevComm();

                Chimera6 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC6 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera6.Initialize("ChimeraLin", settings);
                DUTDC6.Initialize("ChimeraLin", DUTsettings);
                Chimera6.Write("OpenCollectors", collect);

                result.Clear();
                data.Clear();
                data.Add("Data", "0xBB");
                //send data
                Chimera6.Do("SendData", data);
                //recieve data
                DUTDC6.Do("ReadData", out result);
                answer3 = result["Data"].ToString();

                Chimera6.Dispose();
                DUTDC6.Dispose();

                DevComm Chimera7 = new DevComm();
                DevComm DUTDC7 = new DevComm();

                Chimera7 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                DUTDC7 = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
                Chimera7.Initialize("ChimeraLin", settings);
                DUTDC7.Initialize("ChimeraLin", DUTsettings);
                Chimera7.Write("OpenCollectors", collect);

                result.Clear();
                data.Clear();
                data.Add("Data", "0xAA");
                //send data
                Chimera7.Do("SendData", data);
                //recieve data
                DUTDC7.Do("ReadData", out result);
                answer4 = result["Data"].ToString();

                // Switch off all open collectors
                collect.Clear();
                collect.Add("Value", "0x00");
                collect.Add("Mask", "0x0F");
                Chimera7.Write("OpenCollectors", collect);
                Chimera7.Dispose();
                DUTDC7.Dispose();

                System.Diagnostics.Debug.WriteLine("Revcomm Singlewire 2 test data: " + answer1 + " " + answer2 + " " + answer3 + " " + answer4);
                echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3 + " " + answer4);

                if (answer1 == "238" && answer2 == "204" && answer3 == "187" && answer4 == "170")
                {
                    echo("Singlewire 2 Reception Tests Passed!!!");
                    recep = true;
                }
                if (trans == true && recep == true)
                {
                    this.MyForm.SingleWire2.BackColor = Color.Green;
                    this.MyForm.SingleWire2.Refresh();
                    echo("**********Singlewire 2 Tests Passed**********");
                    SINGLEWIRE2 = true;
                }

            }
            catch (Exception ex)
            {
                echo("Error during Singlewire 2 Reception Test");
                echo(" ");
                this.MyForm.SingleWire2.BackColor = Color.Red;
                this.MyForm.SingleWire2.Refresh();
                echo(ex.ToString());
                SINGLEWIRE2 = false;
            }
          
        }

        public void ChimeraInit()
        {

            settings.Add("IP", "10.1.1.2");
            settings.Add("Channel", "2");
            settings.Add("Uart", "2");
            if (onewirechannel == 2)
            {
                settings.Add("LinPort", "LIN2");
            }
            else
            {
                settings.Add("LinPort", "LIN1");
            }
            Chimera.Initialize("ChimeraLin", settings);
            OrderedDictionary val = new OrderedDictionary();
            val = Chimera.Read("Analog");
            string ain1 = val["Ain1"].ToString();
            int i = 0;
            i++;



            settings.Clear();
        }
        public void dallasTest()
        {
            
            DevComm dallasChimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
             settings.Clear();
            settings.Add("IP", "10.1.1.2");
            //settings.Add("Channel", "1");
            dallasChimera.Initialize("ChimeraDallas", settings);
            

            dallasChimera.Initialize("ChimeraDallas", settings);

            OrderedDictionary version = new OrderedDictionary();
           // dallasChimera.Do("GetVersion", out version);
            //string ver;
            //ver = version["Version"].ToString();
           // Console.WriteLine("Chimera Version: " + ver);
            Console.WriteLine("Note: See README.doc for the following errors");
            Console.WriteLine("Error: didnt detect any devices");
            Console.WriteLine("Error: Chimera did not respond. Is it connected?");
            OrderedDictionary roms = new OrderedDictionary();
            String rom0 = null;
            try
            {
               // echo("Getting Dallas Roms");
                dallasChimera.Do("GetDallasRoms", out roms);
                rom0 = roms["rom_0"].ToString();
                Console.WriteLine("Dallas ID: " + rom0);
                echo("Reading Dallas ID...");
                
                this.MyForm.dallas.BackColor = Color.Green;
                this.MyForm.dallas.Refresh();
                echo("Dallas ID: " + rom0);
                Console.WriteLine("Dallas ID: " + rom0);
                DALLAS = true;
            }
            catch (Exception)
            {

                Console.WriteLine("Error ");
                echo("Error reading Dallas ID");
                this.MyForm.dallas.BackColor = Color.Red;
                this.MyForm.dallas.Refresh();
            }
            //dallasChimera.Do("ResetChimera");

        }
        //*************************************************************************************UART TEST**************************************************************************************************
        public void rs232Test()
        {
            
            echo("**********Starting UART Tests**********");

            Boolean UARTTest = false;
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:/ DeviceCommService");
            //Checking RS232 Reception
            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("Mode", "RS232");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("Mode", "RS232");
            DUTsettings.Add("Channel", "1");

            Chimera.Initialize("ChimeraSerial", settings);
            DUTDC.Initialize("ChimeraSerial", DUTsettings);

            OrderedDictionary data = new OrderedDictionary();
            OrderedDictionary recieve = new OrderedDictionary();
            String answer1, answer2, answer3;
            try
            {
                echo(" ");
                echo("Running RS232 Reception Tests...");
                echo("Sending Data: 170 187 204");

                data.Clear();
                data.Add("Data", "0xAA");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out recieve);

                answer1 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xBB");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out recieve);

                answer2 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xCC");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out recieve);

                answer3 = recieve["Data"].ToString();

               

                System.Diagnostics.Debug.WriteLine("Revcomm Singlewire test data: " + answer1 + " " + answer2 + " " + answer3);
                echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3);

                if (answer1 == "170" && answer2 == "187" && answer3 == "204")
                {
                    System.Diagnostics.Debug.WriteLine("RS232 Reception Passed");
                    echo("RS232 Reception Passed");
                    RS232recep = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("RS232 Reception Failed");
                    echo("RS232 Reception Failed");
                    RS232recep = false;
                    this.MyForm.uart_label.BackColor = Color.Red;
                    this.MyForm.uart_label.Refresh();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error trying to send or recieve data during RS232 Reception Test");
                echo("Error trying to send or recieve data during RS232 Reception Tests");
                echo(ex.ToString());
                
                RS232recep = false;
                this.MyForm.uart_label.BackColor = Color.Red;
                this.MyForm.uart_label.Refresh();
            }
            //RS232 Transmission

            try
            {
              
                echo(" ");
                echo("Running RS232 Transmission Tests...");
                echo("Sending Data: 204 170 187");
                data.Clear();
                data.Add("Data", "0xCC");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out recieve);

                answer1 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xAA");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out recieve);

                answer2 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xBB");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out recieve);

                answer3 = recieve["Data"].ToString();



                System.Diagnostics.Debug.WriteLine("Revcomm Singlewire test data: " + answer1 + " " + answer2 + " " + answer3);
                echo("Reading Data: " + answer1 + " " + answer2 + answer3);

                if (answer1 == "204" && answer2 == "170" && answer3 == "187")
                {
                    System.Diagnostics.Debug.WriteLine("RS232 Transmission Passed");
                    echo("RS232 Transmission Passed");
                    RS232trans = true;
                }
                else
                {
                    RS232trans = false;
                    System.Diagnostics.Debug.WriteLine("RS232 Transmission Failed");
                    echo("RS232 Transmission Failed");
                    this.MyForm.uart_label.BackColor = Color.Red;
                    this.MyForm.uart_label.Refresh();
                }
            }
            catch (Exception)
            {
                RS232trans = false;
                System.Diagnostics.Debug.WriteLine("Error trying to send or recieve data during RS232 Transmission Test");
                echo("Error tring to send or recieve data during RS232 Transmission Tests");
                this.MyForm.uart_label.BackColor = Color.Red;
                this.MyForm.uart_label.Refresh();

            }
           
            Chimera.ShutDown();
            DUTDC.ShutDown();
            
        }
        public void rs485Test()
        {
            
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

            echo(" ");
            echo("Running RS485 Reception Test... ");

            //Checking RS485 Reception
            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("Mode", "RS485");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("Mode", "RS485");
            DUTsettings.Add("Channel", "1");

            Chimera.Initialize("ChimeraSerial", settings);
            DUTDC.Initialize("ChimeraSerial", DUTsettings);

            OrderedDictionary data = new OrderedDictionary();
            OrderedDictionary recieve = new OrderedDictionary();
            String answer1, answer2, answer3;
            try
            {
                echo("Sending Data: 170 187 204");
                data.Clear();
                data.Add("Data", "0xAA");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out recieve);

                answer1 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xBB");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out recieve);

                answer2 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xCC");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out recieve);

                answer3 = recieve["Data"].ToString();


                echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3);

                System.Diagnostics.Debug.WriteLine("Revcomm RS485 test data: " + answer1 + " " + answer2 + " " + answer3);

                if (answer1 == "170" && answer2 == "187" && answer3 == "204")
                {
                    System.Diagnostics.Debug.WriteLine("RS485 Reception Passed");
                    echo("RS485 Reception Passed");
                    RS485recep = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("RS485 Reception Failed");
                    echo("RS485 Reception Failed");
                    RS485recep = false;
                    this.MyForm.uart_label.BackColor = Color.Red;
                    this.MyForm.uart_label.Refresh();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error trying to send or recieve data during RS485 Reception Test");
                echo("Error trying to send or recieve data during RS485 Reception Test");
                echo(ex.ToString());
                RS485recep = false;
                UART = false;
                this.MyForm.uart_label.BackColor = Color.Red;
                this.MyForm.uart_label.Refresh();
            }

            // Checking RS485 Transmission

            try
            {
              
                echo(" ");
                echo("Running RS485 Transmission Test... ");
                echo("Sending Data: 204 170 187 ");

                data.Clear();
                data.Add("Data", "0xCC");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out recieve);

                answer1 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xAA");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out recieve);

                answer2 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xBB");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out recieve);

                answer3 = recieve["Data"].ToString();

                echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3);

                System.Diagnostics.Debug.WriteLine("Revcomm RS485 test data: " + answer1 + " " + answer2 + " " + answer3);

                if (answer1 == "204" && answer2 == "170" && answer3 == "187")
                {
                    System.Diagnostics.Debug.WriteLine("RS485 Transmission Passed");
                    echo("RS485 Transmission Passed");
                    RS485trans = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("RS485 Transmission Failed");
                    echo("RS485 Transmission Failed");
                    RS485trans = false;
                    UART = false;
                    this.MyForm.uart_label.BackColor = Color.Red;
                    this.MyForm.uart_label.Refresh();

                }
            }
            catch (Exception)
            {
                System.Diagnostics.Debug.WriteLine("Error trying to send or recieve data during RS485 Transmission Test");
                echo("Error trying to send or recieve data during RS485 Transmission Test");
                RS485trans = false;
                UART = false;
                this.MyForm.uart_label.BackColor = Color.Red;
                this.MyForm.uart_label.Refresh();
            }
           
            Chimera.ShutDown();
            DUTDC.ShutDown();
        }
        public void rs422test()
        {
            
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("Mode", "RS485");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("Mode", "RS422");
            DUTsettings.Add("Channel", "1");

            Chimera.Initialize("ChimeraSerial", settings);
            DUTDC.Initialize("ChimeraSerial", DUTsettings);

            OrderedDictionary data = new OrderedDictionary();
            OrderedDictionary recieve = new OrderedDictionary();
            String answer1, answer2, answer3;


            // Checking RS422 Transmission

            try
            {
                echo(" ");
                echo("Running RS422 Transmission Test...");

                echo("Sending Data: 204 170 187");

                data.Clear();
                data.Add("Data", "0xCC");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out recieve);

                answer1 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xAA");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out recieve);

                answer2 = recieve["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xBB");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out recieve);

                answer3 = recieve["Data"].ToString();



                System.Diagnostics.Debug.WriteLine("Revcomm RS422 test data: " + answer1 + " " + answer2 + " " + answer3);
               

                echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3);

                if (answer1 == "204" && answer2 == "170" && answer3 == "187")
                {
                    System.Diagnostics.Debug.WriteLine("RS422 Transmission Passed");
                    echo("RS422 Transmission Passed");
                    RS422Trans = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("RS422 Transmission Failed");
                    echo("RS422 Transmission Failed");
                    UART = false;
                    RS422Trans = true;
                    this.MyForm.uart_label.BackColor = Color.Red;
                    this.MyForm.uart_label.Refresh();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error trying to send or recieve data during RS422 Transmission Test");
                echo("Error trying to send or recieve data during RS422 Transmission Test");
                echo(ex.ToString());

                RS422Trans = false;
                this.MyForm.uart_label.BackColor = Color.Red;
                this.MyForm.uart_label.Refresh();
            }
            if(RS422Trans==true && RS232trans == true&& RS232recep==true &&RS485recep==true && RS485trans == true)
            {
                this.MyForm.uart_label.BackColor = Color.Green;
                this.MyForm.uart_label.Refresh();
                echo("**********All UART Tests Passed**********");
                UART = true;
            }
            
            Chimera.ShutDown();
            DUTDC.ShutDown();
        }
        //**************************************************************************************High Speed Can Test************************************************************************************
        
        public void canHighSpeedTest()
        {
            

            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/HighSpeedTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/HighSpeedTester.cmdset", @"C:\DeviceCommService");
            echo("**********Starting High Speed CAN Tests**********");

            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("CanPort", "HighSpeed");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("CanPort", "HighSpeed");
            DUTsettings.Add("Channel", "1");



            Chimera.Initialize("ChimeraCan", settings);
            DUTDC.Initialize("ChimeraCan", DUTsettings);

            OrderedDictionary data = new OrderedDictionary();


            OrderedDictionary result = new OrderedDictionary();
            Boolean highCanTrans = false, highCanRecep = false;

           

            //Checking Transmission from DUT
            try
            {
                echo(" ");
                echo("Running Can High speed Transmission Tests...");
                echo("Sending Data: 170 187 204");
                data.Add("Data", "0xAA");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out result);

                string answer1 = result["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xBB");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out result);

                string answer2 = result["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xCC");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out result);
                string answer3 = result["Data"].ToString();

                bool ans1 = answer1.Equals("170");
                bool ans2 = answer2.Equals("187");
                bool ans3 = answer3.Equals("204");
                echo("Receiving Data: " + answer1 + " " + answer2 + " " + answer3);

                if (ans1 && ans2 && ans3)
                {
                    highCanTrans = true;
                    System.Diagnostics.Debug.WriteLine("High Speed Can Transmission Test Passed");
                    echo("High Speed Can Transmission Tests Passed");
                }

                System.Diagnostics.Debug.WriteLine("can answer1: " + answer1);
                System.Diagnostics.Debug.WriteLine("can answer2: " + answer2);
                System.Diagnostics.Debug.WriteLine("can answer3: " + answer3);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error Sending data for High Speed CAN ");
                echo("Error Sending Data for High Speed CAN");
                echo(" ");
                echo(ex.ToString());
                this.MyForm.highSpeed.BackColor = Color.Red;
                this.MyForm.highSpeed.Refresh();
            }

            //Checking Reception from DUT

            try
            {
                echo(" ");
                echo("Running Can High Speed Reception Tests...");
                data.Clear();
                data.Add("Data", "0xCC");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out result);
                echo("Sending Data: 204 170 187");

                string answer1 = result["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xAA");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out result);

                string answer2 = result["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xBB");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out result);
                string answer3 = result["Data"].ToString();

                bool ans1 = answer1.Equals("204");
                bool ans2 = answer2.Equals("170");
                bool ans3 = answer3.Equals("187");
                echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3);
                if (ans1 && ans2 && ans3)
                {
                    highCanRecep = true;
                    System.Diagnostics.Debug.WriteLine("High Speed Can Reception Test Passed");
                    echo("High Speed Can Reception Test Passed");
                }

                System.Diagnostics.Debug.WriteLine("can Reception answer1: " + answer1);
                System.Diagnostics.Debug.WriteLine("can Reception answer2: " + answer2);
                System.Diagnostics.Debug.WriteLine("can Reception answer3: " + answer3);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error Recieving data for High Speed CAN ");
                echo("Error Recieving Data for High Speed Can");
                echo(" ");
                echo(ex.ToString());
                this.MyForm.highSpeed.BackColor = Color.Red;
                this.MyForm.highSpeed.Refresh();
                HIGHSPEEDCAN = false;
            }
            if(highCanRecep == true && highCanTrans)
            {
                this.MyForm.highSpeed.BackColor = Color.Green;
                this.MyForm.highSpeed.Refresh();
                echo("**********All High Speed CAN Tests Passed**********");
                HIGHSPEEDCAN = true;
            }

            Chimera.ShutDown();
            DUTDC.ShutDown();

        }
        //************************************************************************************Multiplexed Can Test***************************************************************************************
        // Check Low Speed Reception
        Boolean lowCanTest = false;
        public void canLowSpeedTest()
        {
            
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/LowSpeedCanTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/LowSpeedCanTester.cmdset", @"C:\DeviceCommService");

            echo("**********Starting Multiplexed CAN Tests**********");

            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("CanPort", "Muxed");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("CanPort", "Muxed");
            DUTsettings.Add("Channel", "1");

            Boolean trans = false;
            Boolean Recep = false;

            Chimera.Initialize("ChimeraCan", settings);
            DUTDC.Initialize("ChimeraCan", DUTsettings);


            OrderedDictionary data = new OrderedDictionary();


            OrderedDictionary result = new OrderedDictionary();


            

            //Checking Transmission from DUT
            try
            {
                echo(" ");
                echo("Running CAN Low Speed Transmission Tests...");
                data.Add("Data", "0xAA");
                
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out result);

                string answer1 = result["Data"].ToString();
                echo("Sending Data: 170 187 204");
                data.Clear();
                data.Add("Data", "0xBB");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out result);

                string answer2 = result["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xCC");
                DUTDC.Do("SendData", data);
                Chimera.Do("ReadData", out result);
                string answer3 = result["Data"].ToString();

                bool ans1 = answer1.Equals("170");
                bool ans2 = answer2.Equals("187");
                bool ans3 = answer3.Equals("204");

                echo("Recieving Data: " + answer1 + " " + answer2 + " " + answer3);

                if (ans1 && ans2 && ans3)
                {
                    lowCanTest = true;
                    System.Diagnostics.Debug.WriteLine("Low Speed Can Transmission Test Passed");
                    echo("Low Speed Can Transmission Test Passed");
                }

                System.Diagnostics.Debug.WriteLine("can answer1: " + answer1);
                System.Diagnostics.Debug.WriteLine("can answer2: " + answer2);
                System.Diagnostics.Debug.WriteLine("can answer3: " + answer3);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error Sending data for Low Speed CAN ");
                echo("Error Sending data for Low Speed CAN");
                echo(" ");
                echo(ex.ToString());
                MULTICAN = false;
            }

            //Checking Reception from DUT

            try
            {
                echo(" ");
                echo("Running CAN Low Speed Reception Tests...");
                data.Clear();
                data.Add("Data", "0xCC");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out result);

                string answ1 = result["Data"].ToString();

                echo("Sending Data: 204 170 187");
                data.Clear();
                data.Add("Data", "0xAA");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out result);

                string answ2 = result["Data"].ToString();

                data.Clear();
                data.Add("Data", "0xBB");
                Chimera.Do("SendData", data);
                DUTDC.Do("ReadData", out result);
                string answ3 = result["Data"].ToString();

                bool ans1 = answ1.Equals("204");
                bool ans2 = answ2.Equals("170");
                bool ans3 = answ3.Equals("187");

                echo("Receiving Data: " + answ1 + " " + answ2 + " " + answ3);

                if (ans1 && ans2 && ans3)
                {
                    Recep = true;
                    System.Diagnostics.Debug.WriteLine("Low Speed Can Reception Test Passed");
                    echo("Low Speed Can Reception Test Passed");
                }

                System.Diagnostics.Debug.WriteLine("can Reception answer1: " + answ1);
                System.Diagnostics.Debug.WriteLine("can Reception answer2: " + answ2);
                System.Diagnostics.Debug.WriteLine("can Reception answer3: " + answ3);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error Receiving data for Low Speed CAN ");
                echo("Error Receiving data for Low Speed CAN");
                echo(" ");
                echo(ex.ToString());
            }
            if(trans== true && Recep== true)
            {
                lowCanTest = true;
                
            }
            if (muxedHighSpeedCan == true && singleCan == true && lowCanTest == true)
            {
                this.MyForm.multiCan.BackColor = Color.Green;
                this.MyForm.multiCan.Refresh();
                echo("**********All Multiplexed CAN Tests Passed**********");
                MULTICAN = true;
            }
            Chimera.ShutDown();
            DUTDC.ShutDown();

        }
        //************Checking High Speed****************************
        Boolean muxedHighSpeedCan= false;
        public void muxedHighSpeed()
        {
            
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/MuxedHighSpeed.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/MuxedHighSpeed.cmdset", @"C:\DeviceCommService");

            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("CanPort", "Muxed");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("Channel", "1");
            DUTsettings.Add("CanPort", "Muxed");


            Chimera.Initialize("ChimeraCan", settings);
            DUTDC.Initialize("ChimeraCan", DUTsettings);





            OrderedDictionary data = new OrderedDictionary();



            OrderedDictionary result = new OrderedDictionary();
            Boolean Trans = false;
            Boolean Recep = false;

            //High Speed Reception Test
            int recepCount = 1;
            while (Recep != true && recepCount <= 4)
            {
                try
                {
                    if (recepCount > 0 )
                    {
                        Chimera.ShutDown();
                        DUTDC.ShutDown();
                        //System.Threading.Thread.Sleep(100);
                        Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/MuxedHighSpeed.cmdset", @"C:\DeviceCommService");
                        DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/MuxedHighSpeed.cmdset", @"C:\DeviceCommService");
                       // System.Threading.Thread.Sleep(100);
                        Chimera.Initialize("ChimeraCan", settings);
                        DUTDC.Initialize("ChimeraCan", DUTsettings);
                        
                    }
                    echo(" ");
                    echo("Starting Muxed High Speed CAN Reception Tests...");
                    echo("Sending Data: 187 204 170");
                    data.Clear();
                    data.Add("Data", "0xBB");
                   // System.Threading.Thread.Sleep(200);
                    Chimera.Do("SendData", data);
                   // System.Threading.Thread.Sleep(200);
                    DUTDC.Do("ReadData", out result);

                    string answr1 = result["Data"].ToString();
                    System.Diagnostics.Debug.WriteLine("string answer1 data: " + answr1);



                    result.Clear();
                    data.Clear();

                    data.Add("Data", "0xCC");
                    
                    Chimera.Do("SendData", data);
                   // System.Threading.Thread.Sleep(200);
                    DUTDC.Do("ReadData", out result);

                    string answr2 = result["Data"].ToString();

                    System.Diagnostics.Debug.WriteLine("string answer2 data: " + answr2);


                    result.Clear();
                    data.Clear();
                    
                    data.Add("Data", "0xAA");
                    Chimera.Do("SendData", data);
                   // System.Threading.Thread.Sleep(200);
                    DUTDC.Do("ReadData", out result);
                    string answr3 = result["Data"].ToString();

                    System.Diagnostics.Debug.WriteLine("string answer3 data: " + answr3);

                    echo("Reading Data: " + answr1 + " " + answr2 + " " + answr3);

                    bool ans1 = answr1.Equals("187");
                    bool ans2 = answr2.Equals("204");
                    bool ans3 = answr3.Equals("170");

                    if (ans1 && ans2 && ans3)
                    {

                        System.Diagnostics.Debug.WriteLine("Muxed High Speed Can Reception Test Passed");
                        echo("Muxed High Speed CAN Reception Test Passed");
                        Recep = true;
                    }
                    else
                    {
                        Recep = false;
                        recepCount++;
                    }

                    System.Diagnostics.Debug.WriteLine("can  answer1: " + answr1);
                    System.Diagnostics.Debug.WriteLine("can answer2: " + answr2);
                    System.Diagnostics.Debug.WriteLine("can answer3: " + answr3);
                    Chimera.ShutDown();
                    DUTDC.ShutDown();
                }
                catch (Exception ex)
                {

                    if (recepCount < 4)
                    {
                        echo("Error: Retrying Attempt " + recepCount + " of 3");
                    }

                    if (recepCount == 4)
                    {

                        System.Diagnostics.Debug.WriteLine("Muxed High Speed Reception Tests Failed!!! ");
                        echo("Failed to Receive Data for Muxed High Speed CAN ");
                        MULTICAN = false;
                        echo(" ");
                        echo(ex.ToString());
                        this.MyForm.multiCan.BackColor = Color.Red;
                    }

                    recepCount++;
                }
            }

            //Checking High Speed Transmission
            int transCount = 1;
            
            while (Trans != true && transCount <= 4)
                {
                    try
                    {
                        if (transCount > 0)
                        {
                            Chimera.ShutDown();
                            DUTDC.ShutDown();
                       // System.Threading.Thread.Sleep(100);
                        Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/MuxedHighSpeed.cmdset", @"C:\DeviceCommService");
                        DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/MuxedHighSpeed.cmdset", @"C:\DeviceCommService");

                        DUTsettings.Clear();
                        DUTsettings.Add("IP", "10.1.1.3");
                        DUTsettings.Add("Channel", "1");
                        DUTsettings.Add("CanPort", "Muxed");

                        settings.Clear();
                        settings.Add("IP", "10.1.1.2");
                        settings.Add("Channel", "1");
                        settings.Add("CanPort", "Muxed");

                       // System.Threading.Thread.Sleep(100);
                        Chimera.Initialize("ChimeraCan", settings);
                        DUTDC.Initialize("ChimeraCan", DUTsettings);
                            
                        }
                        echo(" ");
                        echo("Running Muxed High Speed CAN Transmission Tests...");

                        data.Clear();
                        data.Add("Data", "0xCC");
                        DUTDC.Do("SendData", data);

                       // System.Threading.Thread.Sleep(200);

                        echo("Sending Data: 204 170 187");

                        Chimera.Do("ReadData", out result);
                       // System.Threading.Thread.Sleep(200);
                        String answer1 = result["Data"].ToString();

                        data.Clear();
                        data.Add("Data", "0xAA");
                        DUTDC.Do("SendData", data);
                       // System.Threading.Thread.Sleep(200);
                        Chimera.Do("ReadData", out result);
                        
                        String answer2 = result["Data"].ToString();

                        data.Clear();
                        data.Add("Data", "0xBB");
                        DUTDC.Do("SendData", data);
                       // System.Threading.Thread.Sleep(200);
                        Chimera.Do("ReadData", out result);
                        String answer3 = result["Data"].ToString();

                        Boolean ans1 = answer1.Equals("204");
                        Boolean ans2 = answer2.Equals("170");
                        Boolean ans3 = answer3.Equals("187");

                        echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3);
                        if (ans1 && ans2 && ans3)
                        {

                            System.Diagnostics.Debug.WriteLine("Muxed High Speed Can Transmission Test Passed");
                            echo("Muxed High Speed CAN Transmission Test Passed");
                            Trans = true;
                    }
                    else
                    {
                       transCount++;
                    }

                        System.Diagnostics.Debug.WriteLine("can Reception answer1: " + answer1);
                        System.Diagnostics.Debug.WriteLine("can Reception answer2: " + answer2);
                        System.Diagnostics.Debug.WriteLine("can Reception answer3: " + answer3);
                    }
                    catch (Exception ex)

                    {
                        if (transCount < 4)
                        {
                            echo("Error: Retrying Attempt " + transCount + " of 3");
                        }
                        if (transCount == 4)
                        {

                            echo("Muxed High Speed Transmission Tests FAILED!!! ");
                            echo("Error: Timed out after too many retrys ");
                            echo(" ");
                            MULTICAN = false;
                            echo(ex.ToString());
                            this.MyForm.multiCan.BackColor = Color.Red;
                            Trans = false;
                        }
                        transCount++;
                    }
                }
        
            if (Recep == true && Trans == true)
            {
              muxedHighSpeedCan = true;
                echo("Muxed High Speed Can Test Passed");
            }
            if(muxedHighSpeedCan==true && singleCan==true && lowCanTest == true)
            {
                this.MyForm.multiCan.BackColor = Color.Green;
                this.MyForm.multiCan.Refresh();
                echo("**********All Muxed High Speed Can Tests Passed**********");
                MULTICAN = true;
            }
            Chimera.ShutDown();
            DUTDC.ShutDown();
        }

        //**********************************************************************SingleWire CAN*************************************************************************************************
        Boolean singleCan = false;
        public void singleCanTest()
        {

            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");

            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("CanPort", "Muxed");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("CanPort", "Muxed");
            DUTsettings.Add("Channel", "1");

            Chimera.Initialize("ChimeraCan", settings);
            DUTDC.Initialize("ChimeraCan", DUTsettings);

            OrderedDictionary data = new OrderedDictionary();



            OrderedDictionary result = new OrderedDictionary();
            Boolean Trans = false;
            Boolean Recep = false;



            //SingleWire Reception
            int recepCount = 1;
            while (Recep == false && recepCount <= 4)
            {


                try
                {
                   
                    echo(" ");
                    echo("Running SingleWire CAN Reception Tests...");
                    echo("Sending Data: 170 187 204");
                    data.Clear();
                    data.Add("Data", "0xAA");
                    Chimera.Do("SendData", data);

                    DUTDC.Do("ReadData", out result);

                    string answr1 = result["Data"].ToString();
                    System.Diagnostics.Debug.WriteLine("string answer1 data: " + answr1);

                    Chimera.ShutDown();
                    DUTDC.ShutDown();
                    Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    Chimera.Initialize("ChimeraCan", settings);
                    DUTDC.Initialize("ChimeraCan", DUTsettings);



                    result.Clear();
                    data.Clear();

                    data.Add("Data", "0xBB");
                    Chimera.Do("SendData", data);
                    System.Threading.Thread.Sleep(200);
                    DUTDC.Do("ReadData", out result);

                    string answr2 = result["Data"].ToString();

                    System.Diagnostics.Debug.WriteLine("string answer2 data: " + answr2);

                    Chimera.ShutDown();
                    DUTDC.ShutDown();
                    Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    Chimera.Initialize("ChimeraCan", settings);
                    DUTDC.Initialize("ChimeraCan", DUTsettings);

                    result.Clear();
                    data.Clear();

                    data.Add("Data", "0xCC");
                    Chimera.Do("SendData", data);
                    System.Threading.Thread.Sleep(200);
                    DUTDC.Do("ReadData", out result);
                    string answr3 = result["Data"].ToString();

                    System.Diagnostics.Debug.WriteLine("string answer3 data: " + answr3);

                    echo("Reading Data: " + answr1 + " " + answr2 + " " + answr3);

                    bool ans1 = answr1.Equals("170");
                    bool ans2 = answr2.Equals("187");
                    bool ans3 = answr3.Equals("204");

                    if (ans1 && ans2 && ans3)
                    {

                        System.Diagnostics.Debug.WriteLine("Single Can Reception Test Passed");
                        echo("SingleWire CAN Reception Test Passed");
                        Recep = true;
                    }
                    else
                    {
                        recepCount++;
                        Recep = false;
                    }

                    System.Diagnostics.Debug.WriteLine("can  answer1: " + answr1);
                    System.Diagnostics.Debug.WriteLine("can answer2: " + answr2);
                    System.Diagnostics.Debug.WriteLine("can answer3: " + answr3);
                }
                catch (Exception ex)
                {
                    if(recepCount < 4 && Recep != true)
                    {
                        echo("Error: Retrying Attempt " + recepCount + " of 3");
                    }
                    if (recepCount == 4)
                    {
                        System.Diagnostics.Debug.WriteLine("Singlewire CAN Reception Tests Failed!!!");
                        echo("Error: Time out after too many retrys");
                        echo(" ");
                        echo(ex.ToString());
                        MULTICAN = false;
                        singleCan = false;
                        Recep = false;
                        this.MyForm.multiCan.BackColor = Color.Red;
                        this.MyForm.multiCan.Refresh();
                    }
                    recepCount++;
                }
            }

            int trycount = 1;
            //Checking SingleWire Transmission
            while (Trans == false && trycount <= 4)
            {
                try
                {
                    
                    Chimera.ShutDown();
                    DUTDC.ShutDown();
                    Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    Chimera.Initialize("ChimeraCan", settings);
                    DUTDC.Initialize("ChimeraCan", DUTsettings);
                    echo(" ");
                    echo("Running Singlewire CAN Transmission Tests...");

                    data.Clear();
                    data.Add("Data", "0xCC");
                    DUTDC.Do("SendData", data);

                    System.Threading.Thread.Sleep(200);

                    echo("Sending Data: 204 170 187");

                    Chimera.Do("ReadData", out result);

                    String answer1 = result["Data"].ToString();

                    Chimera.ShutDown();
                    DUTDC.ShutDown();
                    Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    Chimera.Initialize("ChimeraCan", settings);
                    DUTDC.Initialize("ChimeraCan", DUTsettings);

                    data.Clear();
                    data.Add("Data", "0xAA");
                    DUTDC.Do("SendData", data);
                    System.Threading.Thread.Sleep(200);
                    Chimera.Do("ReadData", out result);

                    String answer2 = result["Data"].ToString();

                    Chimera.ShutDown();
                    DUTDC.ShutDown();
                    Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/SingleWireCanTester.cmdset", @"C:\DeviceCommService");
                    Chimera.Initialize("ChimeraCan", settings);
                    DUTDC.Initialize("ChimeraCan", DUTsettings);

                    data.Clear();
                    data.Add("Data", "0xBB");
                    DUTDC.Do("SendData", data);
                    System.Threading.Thread.Sleep(200);
                    Chimera.Do("ReadData", out result);
                    String answer3 = result["Data"].ToString();

                    Boolean ans1 = answer1.Equals("204");
                    Boolean ans2 = answer2.Equals("170");
                    Boolean ans3 = answer3.Equals("187");

                    echo("Reading Data: " + answer1 + " " + answer2 + " " + answer3);
                    if (ans1 && ans2 && ans3)
                    {

                        System.Diagnostics.Debug.WriteLine("SingleWire Can Transmission Test Passed");
                        echo("SingleWire CAN Transmission Test Passed");
                        Trans = true;
                    }
                    else
                    {
                        trycount++;
                        Trans = false;
                    }


                }
                catch (Exception ex)
                {
                    if(trycount < 4 && Trans !=true)
                    {
                        echo("Error: Retrying Attempt " + trycount + " of 3");
                    }
                    if (trycount == 4)
                    {
                        echo("SingleWire Can Transmission Test Failed ");
                        echo("Error: Timed out after to many retrys");
                        MULTICAN = false;
                        singleCan = false;
                        Trans = false;
                        echo(" ");
                        echo(ex.ToString());
                        this.MyForm.multiCan.BackColor = Color.Red;
                        this.MyForm.multiCan.Refresh();

                    }
                    trycount++;
                    
                }
            }
            if(Recep == true && Trans == true)
            {
                singleCan = true;
                echo("Can Singlewire CAN Test Passed");
            }
            if (muxedHighSpeedCan == true && singleCan == true && lowCanTest == true)
            {
                this.MyForm.multiCan.BackColor = Color.Green;
                this.MyForm.multiCan.Refresh();
                echo("**********All Muxed CAN Tests Passed**********");
                MULTICAN = true;
            }
            else
            {
                this.MyForm.multiCan.BackColor = Color.Red;
                this.MyForm.multiCan.Refresh();
            }

            Chimera.ShutDown();
            DUTDC.ShutDown();

        }
        //************************************************************************************AUX IO*****************************************************************************************************
        Boolean auxIO=false,collector=false;
       
        public void auxIOTest()
        {

            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

            echo("**********Starting AUX IO Tests**********");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("CanPort", "Muxed");
            DUTsettings.Add("Channel", "1");
            DUTDC.Initialize("ChimeraCan", DUTsettings);

            System.Diagnostics.Debug.WriteLine("Test Switches after exposing functionality (feat. 1601) ");
            echo(" ");
            echo("Testing Switches after exposing functionality (feat. 1601) ");

            //System.Diagnostics.Debug.WriteLine("Switch functionllity not currently supported by chimera firmware ");

            //Testing if all of the LEDS are on or flashing

            OrderedDictionary LED = new OrderedDictionary();
            LED.Add("LEDValue", "0x00");
            LED.Add("LEDMask", "0x00");
            DUTDC.Write("GPIO", LED);
            LED.Clear();
            LED.Add("LEDValue", "0x0F");
            LED.Add("LEDMask", "0x0F");
            DUTDC.Write("GPIO", LED);
            popup = new ledpopup();
            popup.StartPosition = FormStartPosition.CenterParent;
            popup.ShowDialog();
            Boolean ledCheck = popup.getLEDTests();
            if (ledCheck)
            {
                echo("LED Tests Passed");
                auxIO = true;
            }
            else
            {
                echo("LED Tests Failed");
                auxIO = false;
                this.MyForm.auxIO.BackColor = Color.Red;
                this.MyForm.auxIO.Refresh();

            }
            if (auxIO == true && collector == true && gpioTests == true)
            {
                this.MyForm.auxIO.BackColor = Color.Green;
                this.MyForm.auxIO.Refresh();
                echo("**********All AUX IO Tests Passed**********");
                AUXIO = true;
            }
            
            DUTDC.ShutDown();

        }
        public void collectorsTest()
        {
            //using ChimeraCan to access chimera Hardware (could use any communication protocol)
            //Intialize devicecom objects with associated devIO commandset file
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

            echo(" ");
            echo("Running Collector Tests...");
            try
            {
                DUTsettings.Clear();
                DUTsettings.Add("IP", "10.1.1.2");
                DUTsettings.Add("CanPort", "Muxed");
                DUTsettings.Add("Channel", "1");
                DUTDC.Initialize("ChimeraCan", DUTsettings);

                OrderedDictionary Data = new OrderedDictionary();
                OrderedDictionary Result = new OrderedDictionary();
                String answer;
                Boolean OC1ON, OC1OFF, OC2ON, OC2OFF, OC3ON, OC3OFF, OC4ON, OC4OFF = false;

                //Open all Collectors
                Data.Add("Value", "0x01");
                Data.Add("Mask", "0x0F");
                DUTDC.Write("OpenCollectors", Data);
                Data.Clear();

                //OC1 Test ********************************************
                Data.Add("Value", "0x01");
                Data.Add("Mask", "0x01");
                DUTDC.Write("OpenCollectors", Data);
                Data.Clear();

                DUTDC.Do("REoutRead", out Result);

                echo("OC1 On Test...");
                answer = Result["RE0"].ToString();

                echo("RE0 ON Reading: " + answer);

                if (answer == "0")
                {
                    System.Diagnostics.Debug.WriteLine("OC1 ON Test passed");
                    echo("OC1 ON Test Passed");
                    System.Diagnostics.Debug.WriteLine("RE0 answer " + answer);

                    OC1ON = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("OC1 ON Test Failed");
                    echo("OC1 ON Test Failed");
                    echo("REO Reading: " + answer);
                    System.Diagnostics.Debug.WriteLine("OC1 On should pull node to ground, REO not reading 0 ");
                    echo("OC1 ON Should Pull Node to Ground, RE0 not reading 0 ");
                    OC1ON = false;
                }

                Data.Clear();
                Result.Clear();
                Data.Add("Value", "0x00");
                Data.Add("Mask", "0x01");
                DUTDC.Write("OpenCollectors", Data);


                DUTDC.Do("REoutRead", out Result);

                echo("OC1 OFF Test....");
                answer = Result["RE0"].ToString();

                echo("RE0 OFF Reading: " + answer);

                // System.Diagnostics.Debug.WriteLine("RE0 answer " + answer);
                if (answer == "1")
                {
                    System.Diagnostics.Debug.WriteLine("OC1 OFF Test passed");
                    echo("OC1 OFF Test Passed");
                    System.Diagnostics.Debug.WriteLine("RE0 answer " + answer);
                    OC1OFF = true;

                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("OC1 OFF Test Failed");
                    echo("OC1 OFF Test Failed");
                    echo("REO Reading: " + answer);
                    System.Diagnostics.Debug.WriteLine("OC1 OFF should let node go high, REO not reading 1 ");
                    echo("OC1 OFF should let node go high, REO not reading 1 ");
                    OC1OFF = false;
                }

                //0C2 Test *********************************************

                Data.Clear();
                Result.Clear();
                Data.Add("Value", "0x02");
                Data.Add("Mask", "0x02");
                DUTDC.Write("OpenCollectors", Data);


                DUTDC.Do("REoutRead", out Result);

                echo("OC2 ON Test...");
                answer = Result["RE2"].ToString();

                echo("RE2 Reading: " + answer);

                if (answer == "0")
                {
                    System.Diagnostics.Debug.WriteLine("OC2 ON Test passed");
                    echo("OC2 ON Tests Passed");
                    System.Diagnostics.Debug.WriteLine("RE2 answer " + answer);
                    OC2ON = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("OC2 On Test Failed");
                    echo("OC2 On Test Failed");
                    echo("RE2 Reading: " + answer);
                    System.Diagnostics.Debug.WriteLine("OC2 On should pull node to ground, RE2 not reading 0 ");
                    echo("OC2 on should pull node to ground, REO not reading 0 ");
                    OC2ON = false;
                }

                Data.Clear();
                Result.Clear();
                Data.Add("Value", "0x00");
                Data.Add("Mask", "0x02");
                DUTDC.Write("OpenCollectors", Data);


                DUTDC.Do("REoutRead", out Result);

                echo("OC2 OFF Test...");
                answer = Result["RE2"].ToString();

                echo("RE2 Reading: " + answer);

                //System.Diagnostics.Debug.WriteLine("RE2 answer " + answer);
                if (answer == "1")
                {
                    System.Diagnostics.Debug.WriteLine("OC2 OFF Test passed");
                    echo("OC2 Off Test Passed");
                    System.Diagnostics.Debug.WriteLine("RE2 answer " + answer);
                    OC2OFF = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("OC2 OFF Test Failed");
                    echo("OC2 Off Test Failed");
                    echo("RE2 Reading: " + answer);
                    System.Diagnostics.Debug.WriteLine("OC2 OFF should let node go high, RE2 not reading 1 ");
                    echo("OC2 off Should let node go high, RE2 not reading 1");
                    OC2OFF = false;
                }

                //0C3 Test****************************************************************

                Data.Clear();
                Result.Clear();
                Data.Add("Value", "0x04");
                Data.Add("Mask", "0x04");
                DUTDC.Write("OpenCollectors", Data);


                DUTDC.Do("REoutRead", out Result);
                echo("OC3 ON Test...");

                answer = Result["RE4"].ToString();

                echo("RE4 Reading: " + answer);


                if (answer == "0")
                {
                    System.Diagnostics.Debug.WriteLine("OC3 ON Test passed");
                    echo("OC3 On Test Passed");
                    System.Diagnostics.Debug.WriteLine("RE4 answer " + answer);
                    OC3ON = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("OC3 On Test Failed");
                    echo("OC3 On Test Failed");
                    echo("RE4 Reading: " + answer);
                    System.Diagnostics.Debug.WriteLine("OC3 On should pull node to ground, RE4 not reading 0 ");
                    echo("OC3 on should pull node to ground, RE4 not reading 0 ");
                    OC3ON = false;
                }

                Data.Clear();
                Result.Clear();
                Data.Add("Value", "0x00");
                Data.Add("Mask", "0x04");
                DUTDC.Write("OpenCollectors", Data);


                DUTDC.Do("REoutRead", out Result);

                answer = Result["RE4"].ToString();

                //System.Diagnostics.Debug.WriteLine("RE2 answer " + answer);
                if (answer == "1")
                {
                    System.Diagnostics.Debug.WriteLine("OC3 OFF Test passed");
                    echo("OC3 OFF Test Passed");
                    System.Diagnostics.Debug.WriteLine("RE4 answer " + answer);
                    OC3OFF = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("OC3 OFF Test Failed");
                    echo("OC3 Off Test Failed");
                    echo("RE4 Reading: " + answer);
                    System.Diagnostics.Debug.WriteLine("OC3 OFF should let node go high, RE4 not reading 1 ");
                    echo("OC3 off should let node go high, RE4 not reading 1");
                    OC3OFF = false;
                }

                //OC4 Test*****************************************************
                Data.Clear();
                Result.Clear();
                Data.Add("Value", "0x08");
                Data.Add("Mask", "0x08");
                DUTDC.Write("OpenCollectors", Data);


                DUTDC.Do("REoutRead", out Result);

                echo("OC4 ON Test...");
                answer = Result["RE6"].ToString();
                echo("RE6 Reading: " + answer);

                if (answer == "0")
                {
                    System.Diagnostics.Debug.WriteLine("OC4 ON Test passed");
                    echo("OC4 On Test Passed");
                    System.Diagnostics.Debug.WriteLine("RE6 answer " + answer);
                    OC4ON = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("OC4 On Test Failed");
                    echo("OC4 On Test Failed");
                    echo("RE6 Reading: " + answer);
                    System.Diagnostics.Debug.WriteLine("OC4 On should pull node to ground, RE6 not reading 0 ");
                    echo("OC4 On should pull node to ground, RE6 not reading 0");
                    OC4ON = false;
                }

                Data.Clear();
                Result.Clear();
                Data.Add("Value", "0x00");
                Data.Add("Mask", "0x08");
                DUTDC.Write("OpenCollectors", Data);


                DUTDC.Do("REoutRead", out Result);
                echo("OC4 OFF Test...");

                answer = Result["RE6"].ToString();
                echo("RE6 Reading: " + answer);

                //System.Diagnostics.Debug.WriteLine("RE2 answer " + answer);
                if (answer == "1")
                {
                    System.Diagnostics.Debug.WriteLine("OC4 OFF Test passed");
                    echo("OC4 Off Test Passed");
                    System.Diagnostics.Debug.WriteLine("RE6 answer " + answer);
                    OC4OFF = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("OC4 OFF Test Failed");
                    echo("OC4 OFF Off Test Failed");
                    echo("RE6 Reading: " + answer);
                    System.Diagnostics.Debug.WriteLine("OC4 OFF should let node go high, RE6 not reading 1 ");
                    echo("OC4 Off should let node go high, RE6 not reading 1");
                    OC4OFF = false;
                }
                if (OC1ON && OC1OFF && OC2ON && OC2OFF && OC3ON && OC3OFF && OC4ON && OC4OFF)
                {
                    System.Diagnostics.Debug.WriteLine("All Collector TESTS PASSED !!!!! ");
                    collector = true;
                    echo("All Collector Tests Passed");
                }
            }catch(Exception ex)
            {
                echo("Error during Collector Tests");
                echo(" ");
                echo(ex.ToString());
                this.MyForm.auxIO.BackColor = Color.Red;
                this.MyForm.auxIO.Refresh();
            }
            if(auxIO== true && collector==true && gpioTests == true)
            {
                this.MyForm.auxIO.BackColor = Color.Green;
                this.MyForm.auxIO.Refresh();
                echo("**********All AUX IO Tests Passed **********");
                AUXIO = true;
            }
        }
        //GPIO Test
        Boolean gpioTests = false;
        public void gpioTest()
        {
            //Using ChimeraCan to access Chimera Hardware
            //Initalize devicecomm objects with associated devIO commandset file

            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
          int testCount = 0;

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("CanPort", "Muxed");
            DUTsettings.Add("Channel", "2");
            DUTDC.Initialize("ChimeraCan", DUTsettings);

            try
            {
                double[] RE = { 0, 0, 0, 0, 0, 0, 0, 0 };
                String[] GPIO_Pos = { "RE0", "RE1", "RE2", "RE3", "RE4", "RE5", "RE6", "RE7" };
                Boolean[] EvalRE_Low = { true, true, true, true, true, true, true, true };
                Boolean[] EvalRE_High = { true, true, true, true, true, true, true, true };

                //open collectors OFF
                //Test GPIO RE 0-7 can read logic High

                OrderedDictionary Data = new OrderedDictionary();
                OrderedDictionary Result = new OrderedDictionary();

                echo(" ");
                echo("Running GPIO Test...");

                Data.Clear();
                //Lines Let High
                Data.Add("Value", "0x00");
                Data.Add("Mask", "0x0F");
                DUTDC.Write("OpenCollectors", Data);
                echo("Setting Lines High...");
                DUTDC.Do("REoutRead", out Result);

                RE[0] = Convert.ToDouble(Result["RE0"]);
                RE[1] = Convert.ToDouble(Result["RE1"]);
                RE[2] = Convert.ToDouble(Result["RE2"]);
                RE[3] = Convert.ToDouble(Result["RE3"]);
                RE[4] = Convert.ToDouble(Result["RE4"]);
                RE[5] = Convert.ToDouble(Result["RE5"]);
                RE[6] = Convert.ToDouble(Result["RE6"]);
                RE[7] = Convert.ToDouble(Result["RE7"]);
                for (int i = 0; i < 8; i++)
                {
                    System.Diagnostics.Debug.WriteLine("RE" + (i) + " Read: " + RE[i]);
                    echo("RE" + i + " Read: " + RE[i]);
                    if (Convert.ToDouble(RE[i]) == 0)
                    {
                        EvalRE_Low[i] = false;
                        System.Diagnostics.Debug.WriteLine("GPIO " + GPIO_Pos[i] + " Failed low voltage read! ");
                        echo("GPIO " + GPIO_Pos[i] + " Failed low voltage read! ");
                    }
                    else
                    {
                        EvalRE_Low[i] = true;
                        testCount++;
                    }
                }
                //Open Collectors On
                //Test GPIO RE 0-7 can read logic Low
                //Lines Pulled Low
                echo("Lines Getting Pulled Low");
                Data.Clear();
                Result.Clear();
                Data.Add("Value", "0x0F");
                Data.Add("Mask", "0x0F");
                DUTDC.Write("OpenCollectors", Data);

                DUTDC.Do("REoutRead", out Result);

                RE[0] = Convert.ToDouble(Result["RE0"]);
                RE[1] = Convert.ToDouble(Result["RE1"]);
                RE[2] = Convert.ToDouble(Result["RE2"]);
                RE[3] = Convert.ToDouble(Result["RE3"]);
                RE[4] = Convert.ToDouble(Result["RE4"]);
                RE[5] = Convert.ToDouble(Result["RE5"]);
                RE[6] = Convert.ToDouble(Result["RE6"]);
                RE[7] = Convert.ToDouble(Result["RE7"]);
                for (int i = 0; i < 8; i++)
                {
                    System.Diagnostics.Debug.WriteLine("RE" + (i) + " Read: " + RE[i]);
                    echo("RE " + i + " Read:" + RE[i]);

                    if (Convert.ToDouble(RE[i]) == 1)
                    {
                        EvalRE_High[i] = false;
                        System.Diagnostics.Debug.WriteLine("GPIO " + GPIO_Pos[i] + " Failed High voltage read! ");
                        echo("GPIO " + GPIO_Pos[i] + " Failed High Voltage Read! ");

                    }
                    else
                    {
                        EvalRE_High[i] = true;
                        testCount++;
                    }
                }
                if (testCount == 16)
                {
                    echo("ALL GPIO Tests Passed!!");
                    gpioTests = true;

                }
            }catch(Exception ex)
            {
                echo("Error during the GPIO Tests");
                echo(" ");
                this.MyForm.auxIO.BackColor = Color.Red;
                this.MyForm.auxIO.Refresh();
                echo(ex.ToString());
            }
            if (auxIO == true && collector == true && gpioTests == true)
            {
                this.MyForm.auxIO.BackColor = Color.Green;
                this.MyForm.auxIO.Refresh();
                echo("**********All Aux IO Tests Passed**********");
                AUXIO = true;
            }
        }
        //*******************************************************************Signal Conversion***********************************************************************************************************
        Boolean Ain1 = false;
        Boolean Ain2 = false;
        Boolean upperDACA = false;
        Boolean lowerDACA = false;
        Boolean upperDACB = false;
        Boolean lowerDACB = false;
        public void signalConversionTest()
        {
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

            echo("**********Starting Signal Conversion Tests**********");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("LinPort", "LIN1");
            DUTsettings.Add("Channel", "1");
            DUTDC.Initialize("ChimeraLin", DUTsettings);

            OrderedDictionary Result = new OrderedDictionary();
            echo(" ");
            echo("Running Signal Conversion Test...");

            //Upper and Lower Voltage Limit
            double LCL = 1.45;
            double UCL = 1.55;
            string errorMessage = " ";
            try
            {
                Result = DUTDC.Read("Analog");
                echo("Ain 1 & 2 Values Expected to be between" + LCL + " and " + UCL);
                double ain1 = Convert.ToDouble(Result["Ain1"]);
                double ain2 = Convert.ToDouble(Result["Ain2"]);

                System.Diagnostics.Debug.WriteLine("ain 1 and ain 2 values: " + ain1 + " " + ain2);
                echo("AIN 1 Value: " + ain1);
                echo("AIN 2 Value: " + ain2);

                //Check ADC Ain1

                if (ain1 >= LCL && ain1 <= UCL)
                {
                    System.Diagnostics.Debug.WriteLine("Ain1 Test Passed");
                    echo("Ain1 Reading: " + ain1);
                    echo("Ain1 Test Passed");
                    Ain1 = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("Ain1 Test Failed. Expected a value between " + LCL + " v and " + UCL + " v. Actual value was " + ain1);
                    echo("Ain1 Test Failed. Expected a value between " + LCL + "v and " + UCL + "v. Actual value was " + ain1);
                    Ain1 = false;
                }

                //Check ADC Ain2
                if (ain2 >= LCL && ain2 <= UCL)
                {
                    System.Diagnostics.Debug.WriteLine("Ain2 Test Passed");
                    echo("Ain2 Reading: " + ain2);
                    echo("Ain2 Test Passed");
                    Ain2 = true;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("Ain2 Test Failed. Expected a value between " + LCL + " v and " + UCL + " v. Actual value was " + ain2);
                    echo("Ain2 Test Failed. Expected a value between " + LCL + " v and " + UCL + " v. Actual value was " + ain2);
                    Ain2 = false;
                }
                if (Ain1 == true && Ain2 == true && upperDACA == true && lowerDACA == true && upperDACB == true && lowerDACB == true)
                {
                    MyForm.signalconversion.BackColor = Color.Green;
                    this.MyForm.signalconversion.Refresh();


                }
               
               
            }catch(Exception ex)
            {
                echo("Error trying to read AIN values...");
                echo(" ");
                echo(ex.ToString());
                MyForm.signalconversion.BackColor = Color.Red;
                this.MyForm.signalconversion.Refresh();
                SIGNALCON = false;
            }
            DUTDC.ShutDown();
            Chimera.ShutDown();
        }
        

        //*********************Testing Setting Upper Voltage for DAC A ****************************
        public void dacATest()
        {
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

            echo("");
            echo("Running DACA Upper Voltage Test...");

            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("LinPort", "LIN1");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            
            DUTsettings.Add("LinPort", "LIN1");
            DUTsettings.Add("AutoThreshold", "Disabled");
            DUTsettings.Add("Threshold", "160"); //0.0685(v/step)


            Chimera.Initialize("ChimeraLin", settings);
            DUTDC.Initialize("ChimeraLin", DUTsettings);

            OrderedDictionary Data = new OrderedDictionary();
            OrderedDictionary Result = new OrderedDictionary();
            Data.Add("Value", "0x00");
            Data.Add("Mask", "0x0F");
            // Open Collectors off, DUT 1Wire1 connected to tester 1wire1
            echo("Open collector off, DUT 1wire1 connected to tester 1wire1");
            //Ensuring Tester Collector OC1 is OFF to connect DUT_1wire1 to tester_1wire1
            Chimera.Write("OpenCollectors", Data);

            Data.Clear();
            Data.Add("Value", "0x06");
            Data.Add("Mask" , "0xFF");
            Data.Add("Direction", "0x00");
            //Using tester GPIO RE(0,1,2) to select 10k pulldown
            Chimera.Write("GPIO", Data);
            //10k pulldown resistor connected to 1wire1
            echo("Connecting 10K pulldown resistor to 1wire1");
            //Tester GPIO table for selecting pulldown resistors

            //        Write the following values using the tester chimera GPIO
            //        to selct the following resistor on the given line. The
            //        pulldown resistors are connected to a mux and selected
            //        by the Tester GPIO REout pins.



            //   Write Value        Wire Selection     Resistance
            //----------------------------------------------

            //          0x00        none            none

            //          0x04        1Wire 1         1k

            //          0x06        1Wire 1         10k

            //          0x07        1Wire 2         1k

            //          0x05        1Wire 2         10k

            string ans1, ans2, ans3;
            try
            {
                //send data from tester
                Data.Clear();
                Result.Clear();
                echo("Sending Data: 170 187 204");
                Data.Add("Data", "0xAA");
                Chimera.Do("SendData", Data);
                DUTDC.Do("ReadData", out Result);
                 ans1 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("Successfully Sent Data ans1: " + ans1);

                Data.Clear();
                Result.Clear();
                DUTDC.ShutDown();
                Chimera.ShutDown();
                //Have to close and reopen DEVCOMM due to lin slave will not respond otherwise
                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);


                Data.Clear();


                Data.Add("Data", "0xBB");
                Chimera.Do("SendData", Data);
                 

                DUTDC.Do("ReadData", out Result);
                ans2 = Result["Data"].ToString();

                


                System.Diagnostics.Debug.WriteLine("Successfully Sent Data ans2: " + ans2);

                Data.Clear();
                Result.Clear();

                DUTDC.ShutDown();
                Chimera.ShutDown();

                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                Data.Add("Data", "0xCC");
                Chimera.Do("SendData", Data);
                DUTDC.Do("ReadData", out Result);
                 ans3 = Result["Data"].ToString();

                //Data.Clear();
                //Result.Clear();
                //Data.Add("Data", "0xDD");
                //Chimera.Do("SendData", Data);
                //DUTDC.Do("ReadData", out Result);
                //String ans4 = Result["Data"].ToString();

                echo("Reading Data: " + ans1 + " " + ans2 + " " + ans3);

                if (ans1 == "170" && ans2 == "187" && ans3 == "204")
                {

                    System.Diagnostics.Debug.WriteLine("Successfully Sent Data ");
                    upperDACA = true;
                    echo("Dac A upper voltage test passed");
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("Unsuccessfully Sent Data ");
                    upperDACA = false;
                    echo("Dac A upper voltage test failed");

                }
            }catch(Exception ex)
            {
                echo("Error trying to Test DAC A upper voltage...");
                upperDACA = false;
                MyForm.signalconversion.BackColor = Color.Red;
                this.MyForm.signalconversion.Refresh();
                echo(" ");
                SIGNALCON = false;
                echo(ex.ToString());
            }
            Data.Clear();

            Data.Add("Value", "0x00");
            Data.Add("Mask", "0x0F");

            Chimera.Write("OpenCollectors", Data);
            
            Data.Clear();
            Data.Add("Value", "0x00");
            Data.Add("Mask", "0xFF");
            Data.Add("Direction", "0x00");

            Chimera.Write("GPIO", Data);
            //Open collectors and GPIO reset
            DUTDC.ShutDown();
            Chimera.ShutDown();


            //*******************Testing setting lower Voltage for DAC A ************************
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            echo("");
            echo("Running DACA Lower Voltage Test...");

            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("LinPort", "LIN1");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");

            DUTsettings.Add("LinPort", "LIN1");
            DUTsettings.Add("AutoThreshold", "Disabled");
            DUTsettings.Add("Threshold", "90"); //0.0685(v/step)
            //DAC lower voltage test

            Chimera.Initialize("ChimeraLin", settings);
            DUTDC.Initialize("ChimeraLin", DUTsettings);

            //Ensuring tester collector OC1 is OFF to connect DUT_1Wire1 to tester 1wire1
            echo("Ensuring Tester Collector OC1 is OFF To Connect DUT_1Wire1 To Tester 1wire1");

            Data.Clear();
            Data.Add("Value", "0x00");
            Data.Add("Mask", "0x0F");
            Chimera.Write("OpenCollectors",Data);
            //Open Collectors OFF, DUT 1wire1 connected to tester 1wire1
            echo("Open Collector OFF, DUT 1wire1 Connected To Tester 1wire1");
            //Using tester GPIO RE(0,1,2) to select 1k pulldown
            Data.Clear();
            Data.Add("Value", "0x04");
            Data.Add("Mask", "0xFF");
            Data.Add("Direction", "0x00");
            Chimera.Write("GPIO", Data);
            //1k pulldown resistor connected to 1wire1
            echo("Connecting 1k pulldown resistor to 1wire1");
            echo("Sending Data: 187 204 170");
            try
            {
                //send data from tester
                Data.Clear();
                Data.Add("Data", "0xBB");
                Chimera.Do("SendData", Data);

                //Read the result from the buffer
                Result.Clear();
                DUTDC.Do("ReadData", out Result);

                ans1 = Result["Data"].ToString();

                System.Diagnostics.Debug.WriteLine("DAC A Lower Voltage Successfully Sent Data ans1: " + ans1);

                DUTDC.ShutDown();
                Chimera.ShutDown();

                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                Data.Clear();
                Data.Add("Data", "0xCC");
                Chimera.Do("SendData", Data);


                Result.Clear();
                DUTDC.Do("ReadData", out Result);

                ans2 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("DAC A Lower Voltage Successfully Sent Data ans2: " + ans2);

                DUTDC.ShutDown();
                Chimera.ShutDown();

                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                //send data from tester
                Data.Clear();
                Data.Add("Data", "0xAA");
                Chimera.Do("SendData", Data);

                //Read the result from the buffer
                Result.Clear();
                DUTDC.Do("ReadData", out Result);

                ans3 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("DAC A Lower Voltage Successfully Sent Data ans3: " + ans3);
                echo("Reading Data: " + ans1 + " " + ans2 + " " + ans3);

                if (ans1 == "187" && ans2 == "204" && ans3 == "170")
                {
                    echo("Dac A lower voltage test passed");
                    lowerDACA = true;
                }
                else
                {
                    echo("Dac A lower voltage test failed");
                    lowerDACA = false;
                }
            }
            catch(Exception ex)
            {
                echo("Error during DAC A low voltage test");
                lowerDACA = false;
                echo(" ");
                echo(ex.ToString());
                MyForm.signalconversion.BackColor = Color.Red;
                this.MyForm.signalconversion.Refresh();
                SIGNALCON = false;
            }
            
            Data.Clear();

            Data.Add("Value", "0x00");
            Data.Add("Mask", "0x0F");

            Chimera.Write("OpenCollectors", Data);

            Data.Clear();
            Data.Add("Value", "0x00");
            Data.Add("Mask", "0xFF");
            Data.Add("Direction", "0x00");

            Chimera.Write("GPIO", Data);
            //Open collectors and GPIO reset

            if (Ain1 == true && Ain2 == true && upperDACA == true && lowerDACA == true && upperDACB == true && lowerDACB == true)
            {
                MyForm.signalconversion.BackColor = Color.Green;
                this.MyForm.signalconversion.Refresh();
                
                SIGNALCON = true;
            }
           
            

            Chimera.ShutDown();
            DUTDC.ShutDown();
        }
        //*******************************Testing Setting Upper Voltage for DAC B *******************************
        public void dacBTest()
        {
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

            echo("");
            echo("Running DACB Upper Voltage Test...");

            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("LinPort", "LIN1");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");

            DUTsettings.Add("LinPort", "LIN2");
            DUTsettings.Add("AutoThreshold", "Disabled");
            DUTsettings.Add("Threshold", "160"); //0.0685(v/step)


            Chimera.Initialize("ChimeraLin", settings);
            DUTDC.Initialize("ChimeraLin", DUTsettings);

            

            OrderedDictionary Data = new OrderedDictionary();
            OrderedDictionary Result = new OrderedDictionary();
            Data.Add("Value", "0x01");
            Data.Add("Mask", "0x0F");
            // Open Collectors ON, DUT 1Wire2 connected to tester 1wire1

            echo("Open Collector OC1 On, DUT 1wire2 Connected To Tester 1wire1");
            Chimera.Write("OpenCollectors", Data);

            Data.Clear();
            Data.Add("Value", "0x05");
            Data.Add("Mask", "0xFF");
            Data.Add("Direction", "0x00");
            //10k pulldown resistor connected to 1wire2
            echo("Connecting 10k pulldown resistor to 1wire2");
            //send data from tester
            echo("Sending Data: 170 187 204 221");
            string ans1, ans2, ans3, ans4;
            try
            {
                Data.Clear();
                Result.Clear();
                Data.Add("Data", "0xAA");
                Chimera.Do("SendData", Data);
                DUTDC.Do("ReadData", out Result);
                 ans1 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("Upper Voltage DACB Successfully Sent Data ans1: " + ans1);

                Chimera.ShutDown();
                DUTDC.ShutDown();

                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                Data.Clear();
                Result.Clear();
                Data.Add("Data", "0xBB");
                Chimera.Do("SendData", Data);
                DUTDC.Do("ReadData", out Result);
                 ans2 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("Upper Voltage DACB Successfully Sent Data ans2: " + ans2);


                Chimera.ShutDown();
                DUTDC.ShutDown();

                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                Data.Clear();
                Result.Clear();
                Data.Add("Data", "0xCC");
                Chimera.Do("SendData", Data);
                DUTDC.Do("ReadData", out Result);
                 ans3 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("Upper Voltage DACB Successfully Sent Data ans3: " + ans3);

                Data.Clear();
                Result.Clear();

                Chimera.ShutDown();
                DUTDC.ShutDown();

                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                Data.Clear();
                Result.Clear();
                Data.Add("Data", "0xDD");
                Chimera.Do("SendData", Data);
                DUTDC.Do("ReadData", out Result);
                 ans4 = Result["Data"].ToString();

                echo("Reading Data: " + ans1 + " " + ans2 + " " + ans3 + " " + ans4);

                if (ans1 == "170" && ans2 == "187" && ans3 == "204" && ans4 == "221")
                {

                    System.Diagnostics.Debug.WriteLine("Upper Voltage DACB Successfully Passed Test ");
                    echo("Upper Voltage DACB Successfully Passed Test");
                    upperDACB = true;
                }
                else
                {
                    upperDACB = false;
                }
            }catch(Exception ex)
            {
                echo("Error during upper voltage DACB tests");
                echo(" ");
                echo(ex.ToString());
                MyForm.signalconversion.BackColor = Color.Red;
                this.MyForm.signalconversion.Refresh();
                SIGNALCON = false;

            }
            Data.Clear();

            Data.Add("Value", "0x00");
            Data.Add("Mask", "0x0F");

            Chimera.Write("OpenCollectors", Data);

            Data.Clear();
            Data.Add("Value", "0x00");
            Data.Add("Mask", "0xFF");
            Data.Add("Direction", "0x00");

            Chimera.Write("GPIO", Data);
            //Open collectors and GPIO reset

            //*****************Testing Setting Lower Voltage for DAC B ************************************

            Chimera.ShutDown();
            DUTDC.ShutDown();

            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

           
            echo("");
            echo("Running DACB Lower Voltage Test...");
            try
            {
                settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            settings.Add("LinPort", "LIN1");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");

            DUTsettings.Add("LinPort", "LIN2");
            DUTsettings.Add("AutoThreshold", "Disabled");
            DUTsettings.Add("Threshold", "90"); //0.0685(v/step)
            //DAC lower voltage test

            Chimera.Initialize("ChimeraLin", settings);
            DUTDC.Initialize("ChimeraLin", DUTsettings);

            //Ensuring tester collector OC1 is on to connect DUT_1Wire2 to tester 1wire1
            echo("Ensuring Tester Collector OC1 is On To Connect DUT_1Wire2 To Tester 1wire1");
            Data.Clear();
            Data.Add("Value", "0x01");
            Data.Add("Mask", "0x0F");
            Chimera.Write("OpenCollectors", Data);
            //Open Collectors On, DUT 1wire2 connected to tester 1wire1
            echo("Open Collector OC1 ON, DUT 1wire2 Connected To Tester 1wire1 ");
             //Using tester GPIO RE(0,1,2) to select 1.5k pulldown
            
            Data.Clear();
            Data.Add("Value", "0x07");
            Data.Add("Mask", "0xFF");
            Data.Add("Direction", "0x00");
            Chimera.Write("GPIO", Data);
            //1k pulldown resistor connected to 1wire1
            echo("Connecting 1k Pulldown Resistor To 1wire1");
            echo("Sending Data: 187 204 170 221");
            //send data from tester
           

                Data.Clear();
                Data.Add("Data", "0xBB");
                Chimera.Do("SendData", Data);

                //Read the result from the buffer
                Result.Clear();
                DUTDC.Do("ReadData", out Result);

                ans1 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("Lower Voltage DACB Successfully Sent Data ans1: " + ans1);

                Chimera.ShutDown();
                DUTDC.ShutDown();

                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                Data.Clear();
                Data.Add("Data", "0xCC");
                Chimera.Do("SendData", Data);


                Result.Clear();
                DUTDC.Do("ReadData", out Result);

                ans2 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("Lower Voltage DACB Successfully Sent Data ans2: " + ans2);

                Chimera.ShutDown();
                DUTDC.ShutDown();

                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                //send data from tester
                Data.Clear();
                Data.Add("Data", "0xAA");
                Chimera.Do("SendData", Data);

                //Read the result from the buffer
                Result.Clear();
                DUTDC.Do("ReadData", out Result);

                ans3 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("Lower Voltage DACB Successfully Sent Data ans3: " + ans3);

                Chimera.ShutDown();
                DUTDC.ShutDown();

                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                Chimera.Initialize("ChimeraLin", settings);
                DUTDC.Initialize("ChimeraLin", DUTsettings);

                //send data from tester
                Data.Clear();
                Data.Add("Data", "0xDD");
                Chimera.Do("SendData", Data);

                //Read the result from the buffer
                Result.Clear();
                DUTDC.Do("ReadData", out Result);

                ans4 = Result["Data"].ToString();
                System.Diagnostics.Debug.WriteLine("Lower Voltage DACB Successfully Sent Data ans4: " + ans4);

                echo("Reading Data: " + ans1 + " " + ans2 + " " + ans3 + " " + ans4);
                if (ans1 == "187" && ans2 == "204" && ans3 == "170" && ans4 == "221")
                {
                    echo("Dac B lower voltage test passed");
                    lowerDACB = true;
                }
                else
                {
                    echo("Dac B lower voltage test failed");
                    lowerDACB = false;
                }
                Data.Clear();

                Data.Add("Value", "0x00");
                Data.Add("Mask", "0x0F");

                Chimera.Write("OpenCollectors", Data);

                Data.Clear();
                Data.Add("Value", "0x00");
                Data.Add("Mask", "0xFF");
                Data.Add("Direction", "0x00");

                Chimera.Write("GPIO", Data);
                //Open collectors and GPIO reset
                if (Ain1 == true && Ain2 == true && upperDACA == true && lowerDACA == true && upperDACB == true && lowerDACB == true)
                {
                    MyForm.signalconversion.BackColor = Color.Green;
                    this.MyForm.signalconversion.Refresh();
                    echo("**********All Signal Conversion Tests Passed**********");
                    SIGNALCON = true;
                }
                
            }
            catch(Exception ex)
            {
                echo("Error during DACB low voltage test");
                echo(" ");
                echo(ex.ToString());
                MyForm.signalconversion.BackColor = Color.Red;
                this.MyForm.signalconversion.Refresh();
                SIGNALCON = false;
            }
            Chimera.ShutDown();
            DUTDC.ShutDown();
        }
        //*************************************************************Voltage IO*********************************************************************************************************************
        Boolean ignition1,ignition2, battery1,battery2, reverse1,reverse2, reverse3 = false;
        public void IgnitionTest()
        {
            try
            {
                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                echo("**********Starting Voltage IO Tests**********");
                echo(" ");
                echo("Running Ignition Test...");

                settings.Clear();
                settings.Add("IP", "10.1.1.3");
                settings.Add("Channel", "1");
                settings.Add("CanPort", "Muxed");

                DUTsettings.Clear();
                DUTsettings.Add("IP", "10.1.1.2");

                DUTsettings.Add("Channel", "1");
                DUTsettings.Add("CanPort", "Muxed");

                Chimera.Initialize("ChimeraCan", settings);
                DUTDC.Initialize("ChimeraCan", DUTsettings);

                double gain = 6.76;     //Voltage gain from voltage divider on tester
                double v_on = 14.6;     //Expected Voltage, slightly less than vunreg=14.8
                double tol = .1;        //Tolerance for test pass/fail

                double vhigh = (v_on + (v_on * tol));
                double vlow = (v_on - (v_on * tol));

                //all three lines are connected to same node on test
                //v_IGN and V_BAT are switched off, V_REV to Open/comm
                echo("V_IGN and V_BAT are switched off, V_REV set to Open/Comm");
                //V_IGN: OFF, V_BAT: OFF, V_REV: OPEN

                OrderedDictionary Data = new OrderedDictionary();
                OrderedDictionary Result = new OrderedDictionary();

                Data.Add("State", "0x00");
                DUTDC.Write("Ignition", Data);
                DUTDC.Write("Battery", Data);
                Data.Clear();
                Data.Add("State", "0x02");
                DUTDC.Write("Reverse", Data);

                //Verify the line voltage is low

                Result = Chimera.Read("Analog");

                System.Diagnostics.Debug.WriteLine(Result["Ain1"] + " V");
                double result = Convert.ToDouble(Result["Ain1"]) * gain;

                System.Diagnostics.Debug.WriteLine("Line Voltage is: " + result + " v. Expected is 0 v");
                echo("Line Voltage is: " + result + " v. Expected is 0 v");

                if (result >.05)
                {
                    System.Diagnostics.Debug.WriteLine("Line Voltage is not 0 as expected ");
                    echo("Error: Line voltage is outside the acceptable range");
                    MyForm.voltageIO.BackColor = Color.Red;
                    this.MyForm.voltageIO.Refresh();
                    ignition1 = false;
                }
                else
                {
                    ignition1 = true;
                }

                //Switch on ignition line
                Data.Clear();
                Data.Add("State", "0x01");
                DUTDC.Write("Ignition", Data);
                DUTDC.Write("Battery", Data);
                Data.Clear();
                Data.Add("State", "0x02");
                DUTDC.Write("Reverse", Data);

                //Verify the line voltage is low

                Result = Chimera.Read("Analog");

                System.Diagnostics.Debug.WriteLine(Result["Ain1"] + " v");
                result = Convert.ToDouble(Result["Ain1"]) * gain;
                System.Diagnostics.Debug.WriteLine("Line Voltage is: " + result + " v. Expected is " + v_on + " v");
                echo("Ignition Line Voltage Range Must Be Within " + vlow + " and " + vhigh);
                echo("Line Voltage is: " + result + " v. Expected is " + v_on + " v");

                if (result < vlow || result > vhigh)
                {
                    System.Diagnostics.Debug.WriteLine("Voltage out of " + (tol * 100) + "% tolerance!");
                    echo("Voltage out of " + (tol * 100) + "% tolerance!");
                    MyForm.voltageIO.BackColor = Color.Red;
                    this.MyForm.voltageIO.Refresh();
                    ignition2 = false;
                }
                else
                {
                    if (ignition1) { 
                    echo("Ignition Test Passed");
                    }
                    ignition2 = true;
                    
                }
            }catch(Exception ex)
            {
                echo("Error during Voltage IO tests");
                echo(" ");
                echo(ex.ToString());
                VOLTAGEIO = false;
            }

           
        }
        public void batteryTest()
        {
            try
            {
                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                settings.Clear();
                settings.Add("IP", "10.1.1.3");
                settings.Add("Channel", "1");
                settings.Add("CanPort", "Muxed");

                DUTsettings.Clear();
                DUTsettings.Add("IP", "10.1.1.2");

                DUTsettings.Add("Channel", "1");
                DUTsettings.Add("CanPort", "Muxed");

                Chimera.Initialize("ChimeraCan", settings);
                DUTDC.Initialize("ChimeraCan", DUTsettings);

                echo(" ");
                echo("Running Battery Test...");
                double gain = 6.76;     //Voltage gain from voltage divider on tester
                double v_on = 14.6;     //Expected Voltage, slightly less than vunreg=14.8
                double tol = .1;        //Tolerance for test pass/fail

                double vhigh = (v_on + (v_on * tol));
                double vlow = (v_on - (v_on * tol));

                //all three lines are connected to same node on test
                //v_IGN and V_BAT are switched off, V_REV to Open/comm

                //V_IGN: OFF, V_BAT: OFF, V_REV: OPEN

                OrderedDictionary Data = new OrderedDictionary();
                OrderedDictionary Result = new OrderedDictionary();

                Data.Add("State", "0x00");
                DUTDC.Write("Ignition", Data);
                DUTDC.Write("Battery", Data);
                Data.Clear();
                Data.Add("State", "0x02");
                DUTDC.Write("Reverse", Data);

                //Verify the line voltage is low

                Result = Chimera.Read("Analog");

                System.Diagnostics.Debug.WriteLine(Result["Ain1"] + " V");
                double result = Convert.ToDouble(Result["Ain1"]) * gain;

                System.Diagnostics.Debug.WriteLine("Line Voltage is: " + result + " v. Expected is 0 v");
                echo("Line Voltage is: " + result + " v. Expected is 0 v");

                if (result > 0.05)
                {
                    System.Diagnostics.Debug.WriteLine("Line Voltage is not 0 as expected ");
                    echo("Error: Line voltage is outside the acceptable range");
                    battery1= false;
                }
                else
                {
                    
                    battery1 = true;
                }

                //Switch on ignition line
                Data.Clear();
                Data.Add("State", "0x00");
                DUTDC.Write("Ignition", Data);
                Data.Clear();
                Data.Add("State", "0x01");
                DUTDC.Write("Battery", Data);
                Data.Clear();
                Data.Add("State", "0x02");
                DUTDC.Write("Reverse", Data);

                //Verify the line voltage is low

                Result = Chimera.Read("Analog");

                System.Diagnostics.Debug.WriteLine(Result["Ain1"] + " v");
                result = Convert.ToDouble(Result["Ain1"]) * gain;
                System.Diagnostics.Debug.WriteLine("Line Voltage is: " + result + " v. Expected is " + v_on + " v");
                echo("Battery Line Voltage Range Must Be Within " + vlow + " and " + vhigh);

                echo("Line Voltage is: " + result + " v. Expected is " + v_on + " v");
                if (result < vlow || result > vhigh)
                {
                    System.Diagnostics.Debug.WriteLine("Voltage out of " + (tol * 100) + "% tolerance!");
                    echo("Voltage out of " + (tol * 100) + "% tolerance!");
                    battery2 = false;
                    MyForm.voltageIO.BackColor = Color.Red;
                    this.MyForm.voltageIO.Refresh();
                }
                else
                {
                    if (battery1)
                    {
                        echo("Battery Test Passed");
                    }
                    battery2 = true;
                    
                }
            }catch(Exception ex)
            {
                echo("Error during Battery Tests");
                echo(" ");
                echo(ex.ToString());
                VOLTAGEIO = false;
            }
        }
        public void reverseTest()
        {
            try
            {
                Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
                DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

                settings.Clear();
                settings.Add("IP", "10.1.1.3");
                settings.Add("Channel", "1");
                settings.Add("CanPort", "Muxed");

                echo(" ");
                echo("Running Reverse Line Test...");

                DUTsettings.Clear();
                DUTsettings.Add("IP", "10.1.1.2");
                DUTsettings.Add("Channel", "1");
                DUTsettings.Add("CanPort", "Muxed");

                Chimera.Initialize("ChimeraCan", settings);
                DUTDC.Initialize("ChimeraCan", DUTsettings);

                double gain = 6.76;     //Voltage gain from voltage divider on tester
                double v_on = 14.6;     //Expected Voltage, slightly less than vunreg=14.8
                double tol = .1;        //Tolerance for test pass/fail

                double vhigh = (v_on + (v_on * tol));
                double vlow = (v_on - (v_on * tol));

                //all three lines are connected to same node on test
                //v_IGN and V_BAT are switched off, V_REV to Open/comm

                //V_IGN: OFF, V_BAT: OFF, V_REV: OPEN

                OrderedDictionary Data = new OrderedDictionary();
                OrderedDictionary Result = new OrderedDictionary();

                Data.Add("State", "0x00");
                DUTDC.Write("Ignition", Data);
                DUTDC.Write("Battery", Data);
                Data.Clear();
                Data.Add("State", "0x02");
                DUTDC.Write("Reverse", Data);

                //Verify the line voltage is low

                Result = Chimera.Read("Analog");

                System.Diagnostics.Debug.WriteLine(Result["Ain1"] + " V");
                double result = Convert.ToDouble(Result["Ain1"]) * gain;
                echo("Verifying the line voltage is low");
                System.Diagnostics.Debug.WriteLine("Reverse Line voltage is: " + result + " v. Expected is 0 v");
                echo("Reverse Line Voltage is: " + result + " v. Expected is 0 v");

                if (result > 0.05)
                {
                    System.Diagnostics.Debug.WriteLine("Reverse Line Voltage is not 0 as expected ");
                    echo("Error: Reverse Line voltage is outside the acceptable range");
                    reverse1 = false;
                }
                else
                {
                    reverse1 = true;
                }
               

                //Verify V_REV off
                Data.Clear();
                Data.Add("State", "0x00");
                DUTDC.Write("Ignition", Data);
                Data.Clear();
                Data.Add("State", "0x00");
                DUTDC.Write("Battery", Data);
                Data.Clear();
                Data.Add("State", "0x00");
                DUTDC.Write("Reverse", Data);

                //Verify the line voltage is low

                Result = Chimera.Read("Analog");
                echo("Turning V_REV off");
                System.Diagnostics.Debug.WriteLine(Result["Ain1"] + " v");
                result = Convert.ToDouble(Result["Ain1"]) * gain;
                System.Diagnostics.Debug.WriteLine("Reverse Line Voltage is: " + result + " v. Expected is 0v");
                echo("Reverse Line Voltage is: " + result + " v. Expected is 0v");

                if (result > 0.07)
                {
                    System.Diagnostics.Debug.WriteLine("Error: Reverse Line Voltage is outside the acceptable range");
                    echo("Error: Reverse Line Voltage is outside the acceptable range");
                    reverse2 = false;
                }
                else
                {
                    
                    reverse2 = true;
                }
                

                //Verify V_REV ON
                Data.Clear();
                Data.Add("State", "0x00");
                DUTDC.Write("Ignition", Data);
                Data.Clear();
                Data.Add("State", "0x00");
                DUTDC.Write("Battery", Data);
                Data.Clear();
                Data.Add("State", "0x01");
                DUTDC.Write("Reverse", Data);

                //Verify V_REV on

                Result = Chimera.Read("Analog");

                System.Diagnostics.Debug.WriteLine(Result["Ain1"] + " v");
                result = Convert.ToDouble(Result["Ain1"]) * gain;
                System.Diagnostics.Debug.WriteLine("Reverse Line Voltage On Is: " + result);
                echo("Reverse Line Voltage Range Must Be Within " + vlow + " and " + vhigh);
                echo("Reverse Line Voltage On Is: " + result);
                
                if (result < vlow || result > vhigh)
                {
                    System.Diagnostics.Debug.WriteLine("Reverse Line Voltage On out of " + (tol * 100) + "% tolerance!");
                    echo("Reverse Line Voltage On out of " + (tol * 100) + "% tolerance!");
                    reverse3 = false;
                    MyForm.voltageIO.BackColor = Color.Red;
                    this.MyForm.voltageIO.Refresh();
                }
                else
                {
                    if (reverse1 && reverse2)
                    {
                        echo("Reverse Line Voltage Test Passed");
                    }
                    reverse3 = true;
                    
                }
                if (reverse1 == true && reverse2 == true && reverse3 == true && battery1==true && battery2==true && ignition1 ==true && ignition2==true)
                {
                    MyForm.voltageIO.BackColor = Color.Green;
                    this.MyForm.voltageIO.Refresh();
                    VOLTAGEIO = true;
                    echo("**********All Voltage IO Tests Passed**********");
                }
                else
                {
                    MyForm.voltageIO.BackColor = Color.Red;
                    this.MyForm.voltageIO.Refresh();
                }
            }catch(Exception ex)
            {
                echo("Error During Reverse Tests");
                echo(" ");
                echo(ex.ToString());
                VOLTAGEIO = false;
            }
        }
        public string addressMAC()
        {
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
              OrderedDictionary address = new OrderedDictionary();

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("LinPort", "LIN1");
            DUTsettings.Add("PullupSelection", "Open");

            Chimera.Initialize("ChimeraLin", DUTsettings);
            address = Chimera.Read("MACAddress");
            string MACaddress = address["Address"].ToString();
            int MACnum = int.Parse(MACaddress, System.Globalization.NumberStyles.HexNumber);
            string hexMAC = "c"+ MACnum.ToString("X");

            System.Diagnostics.Debug.WriteLine("MAC Address: " + hexMAC);
            return hexMAC;   
        }

        public void i2cTest()
        {
            Chimera = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");
            DUTDC = new DevComm("\\\\zf1-smb/SYS/GTM/ChimeraDebugger/CommandSets/ChimeraTester.cmdset", @"C:\DeviceCommService");

            settings.Clear();
            settings.Add("IP", "10.1.1.3");
            settings.Add("Channel", "1");
            

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("Channel", "1");
            

            Chimera.Initialize("ChimeraI2C", settings);
            DUTDC.Initialize("ChimeraI2C", DUTsettings);

            //I2C EEPROM address: 0xA0" This address is hardwired on the debug PCB board

            //Value stored on EEPROM device at EEpromAddress is manually selected and written to prior to test

            OrderedDictionary Data = new OrderedDictionary();
            OrderedDictionary Result = new OrderedDictionary();
            OrderedDictionary Address = new OrderedDictionary();
            String[] strData = new String[2];
            echo(" ");
            echo("Starting I2C Test...");
            try
            {
                echo("Writting data to address 0xAA BB CC");
                echo("Data being Written 187 170 221 238 ");
                Data.Add("Address", "0xAA BB CC ");
                Data.Add("Data", "0xBB AA DD EE");
                String[] Data1 = new String[2];


                DUTDC.Do("WriteEEprom", Data);

                Data.Clear();
            }catch(Exception ex)
            {
                echo("Error Trying To Write To The EEPROM");
                echo(" ");
                echo(ex.ToString());
                this.MyForm.i2cLabel.BackColor = Color.Red;
                this.MyForm.i2cLabel.Refresh();
            }

            try
            {
                echo("Reading From Address 0xAA BB CC");
                String[] Address1 = new String[2];
                Address1[0] = "Address";
                Address1[1] = "0xAA BB CC";

                DUTDC.Do("ReadEEprom", Address1, out strData);

                System.Diagnostics.Debug.WriteLine("Data Being Read: " + strData[1]);
                echo("Data Read Back at Address is: " + strData[1]);

            }catch(Exception ex)
            {
                echo("Error Trying To Read From The EEPROM");
                echo(" ");
                echo(ex.ToString());
                this.MyForm.i2cLabel.BackColor = Color.Red;
                this.MyForm.i2cLabel.Refresh();
            }

            if(strData[1]== "187 170 221 238")
            {
                echo("I2C test passed");
                this.MyForm.i2cLabel.BackColor = Color.Green;
                this.MyForm.i2cLabel.Refresh();
                I2C = true;
            }
            else
            {
                echo("I2C test failed");
            }


        }
    }
}
