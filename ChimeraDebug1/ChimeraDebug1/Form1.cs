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
    public partial class Form1 : Form
    {
        BasicTests Tests;
        public selectTest selTest;
        public search searchForm;
        string dallas_test;
        string singlewire1_test;
        string singlewire2_test;
        string uart_test;
        string hscan_test;
        string multican_test;
        string auxio_test;
        string sigconversion_test;
        string voltageio_test;
        string i2c_test;
        Boolean fullTest = false;
        Boolean allTestPassed = false;
       
        public Form1()

        {
            InitializeComponent();
            Tests = new BasicTests(this);

        }


        private void Start_Click(object sender, EventArgs e)
        {
            //Tests.dallasTest();
            //Tests.i2cTest();

            //Tests.auxIOTest();

            Tests.muxedHighSpeed();

            Console.WriteLine("done");

        }



        private void label1_Click_1(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {

            }
        }

        public void log_TextChanged(object sender, EventArgs e)
        {

        }

        private void button3_Click(object sender, EventArgs e)
        {
            log.Text = String.Empty;
            dallas.BackColor = default(Color);
            dallas.Refresh();
            SingleWire1.BackColor = default(Color);
            SingleWire1.Refresh();
            SingleWire2.BackColor = default(Color);
            SingleWire2.Refresh();
            uart_label.BackColor = default(Color);
            uart_label.Refresh();
            highSpeed.BackColor = default(Color);
            highSpeed.Refresh();
            multiCan.BackColor = default(Color);
            multiCan.Refresh();
            auxIO.BackColor = default(Color);
            auxIO.Refresh();
            voltageIO.BackColor = default(Color);
            voltageIO.Refresh();
            signalconversion.BackColor = default(Color);
            signalconversion.Refresh();
            i2cLabel.BackColor = default(Color);
            i2cLabel.Refresh();
            Tests.clearlog();
            try
            {
                Tests.dallasTest();
                
                //SingleWire1
                Tests.pullUpDownTest();
                Tests.singleWire1Test();
                

                //SingleWire2
                Tests.singleWire2Test();
               

                //UART Tests
                Tests.rs232Test();
                Tests.rs485Test();
                Tests.rs422test();

                //Can Tests

                Tests.canHighSpeedTest();
                //Can multiplexed high speed test?
                Tests.muxedHighSpeed();
                Tests.canLowSpeedTest();
                Tests.singleCanTest();


                //Aux IO Tests
                Tests.auxIOTest();
                Tests.collectorsTest();
                Tests.gpioTest();



                //Voltage IO
                Tests.IgnitionTest();
                Tests.batteryTest();
                Tests.reverseTest();

                //Signal Conversion
                Tests.signalConversionTest();
                Tests.dacATest();
                Tests.dacBTest();

                //I2c
                Tests.i2cTest();
                fullTest = true;
              


                if (Tests.getHIGHSPEEDCAN())
            {
                hscan_test = "Pass";
            }
            else
            {
                hscan_test = "Fail";
            }
            if (Tests.getI2C())
            {
                i2c_test = "Pass";
            }
            else
            {
                i2c_test = "Fail";
            }
            if (Tests.getSIGNALCON())
            {
                sigconversion_test = "Pass";
            }
            else
            {
                sigconversion_test = "Fail";
            }
            if (Tests.getSINGLEWIRE1())
            {
                singlewire1_test = "Pass";
            }
            else
            {
                singlewire1_test = "Fail";
            }
            if (Tests.getSINGLEWIRE2())
            {
                singlewire2_test = "Pass";
            }
            else
            {
                singlewire2_test = "Fail";
            }
            if (Tests.getVOLTAGEIO())
            {
                voltageio_test = "Pass";
            }
            else
            {
                voltageio_test = "Fail";
            }
            if (Tests.getUART())
            {
                uart_test = "Pass";
            }
            else
            {
                uart_test = "Fail";
            }
            if (Tests.getMUlTICAN())
            {
                multican_test = "Pass";
            }
            else
            {
                multican_test = "Fail";
            }
            if (Tests.getDallas())
            {
                dallas_test = "Pass";
            }
            else
            {
                dallas_test = "Fail";
            }
            if (Tests.getAUIXO())
            {
                auxio_test = "Pass";
            }
            else
            {
                auxio_test = "Fail";
            }





            if (Tests.getHIGHSPEEDCAN() && Tests.getI2C() && Tests.getSIGNALCON() && Tests.getMUlTICAN() && Tests.getSINGLEWIRE1() && Tests.getSINGLEWIRE2() && Tests.getVOLTAGEIO() && Tests.getUART() && Tests.getUART() && Tests.getAUIXO())
            {
                allTestPassed = true;
                Pass pass = new Pass(this);
                pass.StartPosition = FormStartPosition.CenterParent;
                pass.ShowDialog();
               
            }
            else
            {
                allTestPassed = false;
                
                   FailLog fail = new FailLog(this);
                    fail.StartPosition = FormStartPosition.CenterParent;
                    fail.ShowDialog();
                    
                
            }
                
            }
            catch (Exception ex)
            {

                log.Text = "Chimera did not respond. Please verify the connections. Also verify that the chimera being tested IP  is set to 10.1.1.2";
            }
            try
            {
                File.WriteAllText("Documents/ChimeraLog.txt", log.Text);
            }
            catch
            {

            }

        }
        public String getlogdata()
        {
            return Tests.getlog();
        }
        private void dallas_Click(object sender, EventArgs e)
        {
        }
        public string get_hscan()
        {
            return hscan_test;
        }
        public string get_i2c()
        {
            return i2c_test;
        }
        public string get_sigCon()
        {
            return sigconversion_test;
        }
        public string get_singlewire1()
        {
            return singlewire1_test;
        }
        public string get_singlewire2()
        {
            return singlewire2_test;
        }
        public string get_voltageIO()
        {
            return voltageio_test;
        }
        public Boolean get_allTestPassed()
        {
            return allTestPassed;
        }

        public string get_UART()
        {
            return uart_test;
        }
        public string get_multiCAN()
        {
            return multican_test;
        }
        public string get_dallas()
        {
            return dallas_test;
        }
        public string get_auxIO()
        {
            return auxio_test;
        }
        public string get_macAddress()
        {
            return Tests.addressMAC();
        }
        private void selectTest_Click(object sender, EventArgs e)
        {
            dallas.BackColor = default(Color);
            dallas.Refresh();
            SingleWire1.BackColor = default(Color);
            SingleWire1.Refresh();
            SingleWire2.BackColor = default(Color);
            SingleWire2.Refresh();
            uart_label.BackColor = default(Color);
            uart_label.Refresh();
            highSpeed.BackColor = default(Color);
            highSpeed.Refresh();
            multiCan.BackColor = default(Color);
            multiCan.Refresh();
            auxIO.BackColor = default(Color);
            auxIO.Refresh();
            voltageIO.BackColor = default(Color);
            voltageIO.Refresh();
            signalconversion.BackColor = default(Color);
            signalconversion.Refresh();
            i2cLabel.BackColor = default(Color);
            i2cLabel.Refresh();

            log.Text = String.Empty;
            selTest = new selectTest();
            selTest.StartPosition = FormStartPosition.CenterParent;
            selTest.ShowDialog();
            try
            {

                if (selTest.boolDallas == true)
                {
                    Tests.dallasTest();
                }
                if (selTest.boolSinglewire1 == true)
                {
                    Tests.pullUpDownTest();
                    Tests.singleWire1Test();
                }
                if (selTest.boolSinglewire2 == true)
                {
                    Tests.singleWire2Test();
                }
                if (selTest.boolUART == true)
                {
                    Tests.rs232Test();
                    Tests.rs485Test();
                    Tests.rs422test();
                }
                if (selTest.boolDedHSCAN == true)
                {
                    Tests.canHighSpeedTest();
                }
                if (selTest.boolMultiCAN == true)
                {
                    Tests.canLowSpeedTest();
                    Tests.singleCanTest();
                    Tests.muxedHighSpeed();
                }
                if (selTest.boolAuxIO == true)
                {
                    Tests.auxIOTest();
                    Tests.collectorsTest();
                    Tests.gpioTest();
                }
                if (selTest.boolVoltIO == true)
                {
                    Tests.IgnitionTest();
                    Tests.batteryTest();
                    Tests.reverseTest();
                }
                if (selTest.boolSigCon == true)
                {
                    Tests.signalConversionTest();
                    Tests.dacATest();
                    Tests.dacBTest();
                }
                if (selTest.boolI2C == true && selTest.boolDallas == true)
                {
                    Tests.i2cTest();
                }
                else if (selTest.boolI2C == true && selTest.boolDallas == false)
                {
                    Tests.dallasTest();
                    Tests.i2cTest();
                }
                fullTest = false;
            }
            catch (Exception ex)
            {
                log.Text = "Chimera did not respond. Please verify the connections";
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            String address = " ";
            Boolean error = true;
            try
            {
                address = Tests.addressMAC();
                error = false;
                
            }
            catch (Exception ex)
            {
               
                error = true;
                searchForm = new search();
                searchForm.StartPosition = FormStartPosition.CenterParent;
                searchForm.ShowDialog();
            }
            if (!error)
            {
                
                System.Diagnostics.Process.Start("https://testers.gentex.com/webRD/bySerial.php?DB=prod&csv=false&serial=" + address);
            }



        }

        private void button1_Click(object sender, EventArgs e)
        {
            //if (logdata == false)
            //{
            //    logdata = true;
            //}
            //else if (logdata)
            //{
            //    logdata = false;
            //}
            //System.Diagnostics.Debug.WriteLine("Logdata= " + logdata);

            if (fullTest)
            {
                LogData log = new LogData(this);
                log.StartPosition = FormStartPosition.CenterParent;
                log.ShowDialog();
                

                fullTest = false;
            }
            else
            {
                logError logEr = new logError();
                logEr.StartPosition = FormStartPosition.CenterParent;
                logEr.ShowDialog();

            }

            //if (logdata)
            //{
            //    logdata_label.Text = "Results will write to Rich Data ";
            //    logdata_label.ForeColor = System.Drawing.Color.Green;
            //    logdata_label.Refresh();
            //}
            //else
            //{
            //    logdata_label.Text = "Results will not write to Rich Data ";
            //    logdata_label.ForeColor = System.Drawing.Color.DarkRed;
            //    logdata_label.Refresh();
            //}
        }

        private void SingleWire1_Click(object sender, EventArgs e)
        {

        }
    }

    


}