using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ChimeraDebug1
{
    public partial class LogData : Form
    {
        public Form1 MyForm;
        public LogData(Form1 form)
        {
            this.MyForm = form;
            InitializeComponent();
            comboBox1.Items.Add("Centennial East");
            comboBox1.Items.Add("North Riley");
            comboBox1.Items.Add("James St");
        }

        private void listBox1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void richTextBox1_TextChanged(object sender, EventArgs e)
        {

        }

       

        private void label1_Click(object sender, EventArgs e)
        {
            
        }

        private void button1_Click(object sender, EventArgs e)
        {
            string employee = textBox1.Text;
            string building = comboBox1.Text;
            string notes = richTextBox1.Text;
            if(string.IsNullOrEmpty(textBox1.Text) || string.IsNullOrEmpty(comboBox1.Text) || string.IsNullOrEmpty(richTextBox1.Text))
            {
                Error error = new Error();
                error.StartPosition = FormStartPosition.CenterParent;
                error.ShowDialog();
            }
            else
            {
                RichData data = new RichData();
                
               // string MACaddress = tests.addressMAC();

                System.Diagnostics.Debug.WriteLine("employe: "+employee);
                System.Diagnostics.Debug.WriteLine("building: " + building);
                System.Diagnostics.Debug.WriteLine("notes: " + notes);
                DateTime time = DateTime.Now;
                string serial = this.MyForm.get_macAddress();
                string dallas = this.MyForm.get_dallas();
                string singlewire1 = this.MyForm.get_singlewire1();
                string singlewire2 = this.MyForm.get_singlewire2();
                string uart = this.MyForm.get_UART();
                string hscan = this.MyForm.get_hscan();
                string multican = this.MyForm.get_multiCAN();
                string auxIO = this.MyForm.get_auxIO();
                string sigCon = this.MyForm.get_sigCon();
                string voltageIO = this.MyForm.get_voltageIO();
                string i2c = this.MyForm.get_i2c();
                string logdata = this.MyForm.getlogdata();
                System.Diagnostics.Debug.WriteLine(serial+ dallas+ singlewire1+singlewire2+ uart+hscan+multican+auxIO+sigCon+voltageIO+i2c);
                String mac_address = serial.Trim(new Char[] { 'c' });
                System.Diagnostics.Debug.WriteLine("Macc Address is: " + mac_address);
                if (this.MyForm.get_allTestPassed()==true)
                {
                    
                    data.SubmitToRichData(serial,mac_address, time, building, employee, dallas, singlewire1, singlewire2, uart, hscan
                        , multican, auxIO, sigCon, voltageIO, i2c, notes,logdata, Gentex.MES.LegacyDataClient.DataResultEnum.Pass);
                }
                else
                {
                    
                    data.SubmitToRichData(serial,mac_address, time, building, employee, dallas, singlewire1, singlewire2, uart, hscan
                       , multican, auxIO, sigCon, voltageIO, i2c, notes,logdata, Gentex.MES.LegacyDataClient.DataResultEnum.Fail);
                }
                Close();
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Close();
        }
    }
}
