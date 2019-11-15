using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ChimeraDebug1
{
    public partial class search : Form
    {
        private DevComm Chimera = new DevComm();
        private StringDictionary DUTsettings = new StringDictionary();
        private OrderedDictionary address = new OrderedDictionary();

        public search()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Chimera = new DevComm(@"C:\Users\josh.holovka\source\repos\ChimeraDebug1\ChimeraDebug1\CommandSets\ChimeraTester.cmdset", @"C:\DeviceCommService");

            DUTsettings.Clear();
            DUTsettings.Add("IP", "10.1.1.2");
            DUTsettings.Add("LinPort", "LIN1");
            DUTsettings.Add("PullupSelection", "Open");
            Chimera.Initialize("ChimeraLin", DUTsettings);
            address=Chimera.Read("MACAddress");
            string MACaddress = address["Address"].ToString();
            int MACnum = int.Parse(MACaddress);
            string hexMAC = MACnum.ToString("X");

            System.Diagnostics.Debug.WriteLine("MAC Address: " + hexMAC);
            MACAddress.Text=hexMAC;
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void button3_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void button1_Click_1(object sender, EventArgs e)
        {
            Close();
        }
    }
}
