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
    public partial class FailLog : Form
    {
        public Form1 MyForm;
        public FailLog(Form1 form)
        {
            this.MyForm = form;
            InitializeComponent();
        }

        private void no_button2_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void yes_button1_Click(object sender, EventArgs e)
        {
            LogData log = new LogData(MyForm);
            log.StartPosition = FormStartPosition.CenterParent;
            log.ShowDialog();
            Close();
        }
    }
}
