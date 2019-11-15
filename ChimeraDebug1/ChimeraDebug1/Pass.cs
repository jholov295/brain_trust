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
    public partial class Pass : Form
    {
        public Form1 MyForm;
        public Pass(Form1 form)
        {
            this.MyForm = form;
            
            InitializeComponent();
            
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            LogData log = new LogData(MyForm);
            log.StartPosition = FormStartPosition.CenterParent;
            log.ShowDialog();
            Close();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Close();
        }
    }
}
