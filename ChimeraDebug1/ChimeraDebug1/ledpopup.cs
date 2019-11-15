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
    
    public partial class ledpopup : Form
    {
        Boolean LEDtest = false;
        public ledpopup()
        {
            
            InitializeComponent();
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void yes_Click(object sender, EventArgs e)
        {
            setLEDTests(true);
            Close();
        }

        private void no_Click(object sender, EventArgs e)
        {
            setLEDTests(false);
            Close();
        }
        public Boolean getLEDTests()
        {
            return LEDtest;
        }
        public void setLEDTests(Boolean value)
        {
            LEDtest = value;
        }
        
    }
}
