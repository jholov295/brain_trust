using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Timers;
using System.Threading;

namespace ChimeraDebug1
{
    public partial class selectTest : Form
    {
        public Boolean boolDallas=false;
        public Boolean boolSinglewire1=false;
        public Boolean boolSinglewire2 =false;
        public Boolean boolUART =false;
        public Boolean boolDedHSCAN =false;
        public Boolean boolMultiCAN =false;
        public Boolean boolAuxIO =false;
        public Boolean boolSigCon =false;
        public Boolean boolVoltIO =false;
        public Boolean boolI2C =false;

        
        

        public selectTest()
        {
            

            InitializeComponent();
            
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            boolDallas = true;
        }

        private void checkBox9_CheckedChanged(object sender, EventArgs e)
        {
            boolVoltIO = true;
        }

        private void checkBox8_CheckedChanged(object sender, EventArgs e)
        {
            boolSigCon = true;
        }

        private void checkBox7_CheckedChanged(object sender, EventArgs e)
        {
            boolAuxIO = true;
        }

        private void checkBox10_CheckedChanged(object sender, EventArgs e)
        {
            boolI2C = true;
        }

        private void checkBox5_CheckedChanged(object sender, EventArgs e)
        {
            boolDedHSCAN = true;
        }

        private void checkBox4_CheckedChanged(object sender, EventArgs e)
        {
            boolUART = true;
        }

        private void checkBox3_CheckedChanged(object sender, EventArgs e)
        {
            boolSinglewire2 = true;
        }

        private void checkBox2_CheckedChanged(object sender, EventArgs e)
        {
            boolSinglewire1 = true;
        }

        private void checkBox6_CheckedChanged(object sender, EventArgs e)
        {
            boolMultiCAN = true;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Close();
           
            
            
           
           
           
        }
       

        private void button2_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
