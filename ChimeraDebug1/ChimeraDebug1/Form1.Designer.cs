using System.Windows.Forms;

namespace ChimeraDebug1
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.button1 = new System.Windows.Forms.Button();
            this.button2 = new System.Windows.Forms.Button();
            this.log = new System.Windows.Forms.TextBox();
            this.button3 = new System.Windows.Forms.Button();
            this.dallas = new System.Windows.Forms.Label();
            this.SingleWire1 = new System.Windows.Forms.Label();
            this.SingleWire2 = new System.Windows.Forms.Label();
            this.uart_label = new System.Windows.Forms.Label();
            this.highSpeed = new System.Windows.Forms.Label();
            this.multiCan = new System.Windows.Forms.Label();
            this.auxIO = new System.Windows.Forms.Label();
            this.signalconversion = new System.Windows.Forms.Label();
            this.voltageIO = new System.Windows.Forms.Label();
            this.i2cLabel = new System.Windows.Forms.Label();
            this.selectTest = new System.Windows.Forms.Button();
            this.logdata_label = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(42, 308);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(108, 46);
            this.button1.TabIndex = 1;
            this.button1.Text = "Log Data";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(42, 232);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(108, 46);
            this.button2.TabIndex = 2;
            this.button2.Text = "Search";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.Click += new System.EventHandler(this.button2_Click);
            // 
            // log
            // 
            this.log.Location = new System.Drawing.Point(206, 62);
            this.log.Multiline = true;
            this.log.Name = "log";
            this.log.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.log.Size = new System.Drawing.Size(408, 328);
            this.log.TabIndex = 5;
            this.log.TextChanged += new System.EventHandler(this.log_TextChanged);
            // 
            // button3
            // 
            this.button3.Location = new System.Drawing.Point(42, 78);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(108, 49);
            this.button3.TabIndex = 7;
            this.button3.Text = "Full Test";
            this.button3.UseVisualStyleBackColor = true;
            this.button3.Click += new System.EventHandler(this.button3_Click);
            // 
            // dallas
            // 
            this.dallas.AutoSize = true;
            this.dallas.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.dallas.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dallas.Location = new System.Drawing.Point(649, 36);
            this.dallas.Name = "dallas";
            this.dallas.Size = new System.Drawing.Size(47, 16);
            this.dallas.TabIndex = 8;
            this.dallas.Text = "Dallas";
            this.dallas.Click += new System.EventHandler(this.dallas_Click);
            // 
            // SingleWire1
            // 
            this.SingleWire1.AutoSize = true;
            this.SingleWire1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.SingleWire1.Location = new System.Drawing.Point(649, 78);
            this.SingleWire1.Name = "SingleWire1";
            this.SingleWire1.Size = new System.Drawing.Size(81, 16);
            this.SingleWire1.TabIndex = 9;
            this.SingleWire1.Text = "SingleWire1";
            this.SingleWire1.Click += new System.EventHandler(this.SingleWire1_Click);
            // 
            // SingleWire2
            // 
            this.SingleWire2.AutoSize = true;
            this.SingleWire2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.SingleWire2.Location = new System.Drawing.Point(649, 123);
            this.SingleWire2.Name = "SingleWire2";
            this.SingleWire2.Size = new System.Drawing.Size(81, 16);
            this.SingleWire2.TabIndex = 10;
            this.SingleWire2.Text = "SingleWire2";
            // 
            // uart_label
            // 
            this.uart_label.AutoSize = true;
            this.uart_label.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.uart_label.Location = new System.Drawing.Point(649, 168);
            this.uart_label.Name = "uart_label";
            this.uart_label.Size = new System.Drawing.Size(49, 16);
            this.uart_label.TabIndex = 11;
            this.uart_label.Text = "UART ";
            // 
            // highSpeed
            // 
            this.highSpeed.AutoSize = true;
            this.highSpeed.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.highSpeed.Location = new System.Drawing.Point(649, 208);
            this.highSpeed.Name = "highSpeed";
            this.highSpeed.Size = new System.Drawing.Size(111, 16);
            this.highSpeed.TabIndex = 12;
            this.highSpeed.Text = "High Speed CAN";
            // 
            // multiCan
            // 
            this.multiCan.AutoSize = true;
            this.multiCan.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.multiCan.Location = new System.Drawing.Point(649, 245);
            this.multiCan.Name = "multiCan";
            this.multiCan.Size = new System.Drawing.Size(62, 16);
            this.multiCan.TabIndex = 13;
            this.multiCan.Text = "Multi Can";
            // 
            // auxIO
            // 
            this.auxIO.AutoSize = true;
            this.auxIO.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.auxIO.Location = new System.Drawing.Point(649, 287);
            this.auxIO.Name = "auxIO";
            this.auxIO.Size = new System.Drawing.Size(46, 16);
            this.auxIO.TabIndex = 14;
            this.auxIO.Text = "Aux IO";
            // 
            // signalconversion
            // 
            this.signalconversion.AutoSize = true;
            this.signalconversion.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.signalconversion.Location = new System.Drawing.Point(649, 359);
            this.signalconversion.Name = "signalconversion";
            this.signalconversion.Size = new System.Drawing.Size(117, 16);
            this.signalconversion.TabIndex = 15;
            this.signalconversion.Text = "Signal Conversion";
            // 
            // voltageIO
            // 
            this.voltageIO.AutoSize = true;
            this.voltageIO.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.voltageIO.Location = new System.Drawing.Point(649, 322);
            this.voltageIO.Name = "voltageIO";
            this.voltageIO.Size = new System.Drawing.Size(71, 16);
            this.voltageIO.TabIndex = 16;
            this.voltageIO.Text = "Voltage IO";
            // 
            // i2cLabel
            // 
            this.i2cLabel.AutoSize = true;
            this.i2cLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.i2cLabel.Location = new System.Drawing.Point(649, 396);
            this.i2cLabel.Name = "i2cLabel";
            this.i2cLabel.Size = new System.Drawing.Size(27, 16);
            this.i2cLabel.TabIndex = 17;
            this.i2cLabel.Text = "I2C";
            // 
            // selectTest
            // 
            this.selectTest.Location = new System.Drawing.Point(42, 152);
            this.selectTest.Name = "selectTest";
            this.selectTest.Size = new System.Drawing.Size(108, 48);
            this.selectTest.TabIndex = 18;
            this.selectTest.Text = "Select Tests";
            this.selectTest.UseVisualStyleBackColor = true;
            this.selectTest.Click += new System.EventHandler(this.selectTest_Click);
            // 
            // logdata_label
            // 
            this.logdata_label.AutoSize = true;
            this.logdata_label.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            this.logdata_label.Location = new System.Drawing.Point(72, 409);
            this.logdata_label.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.logdata_label.Name = "logdata_label";
            this.logdata_label.Size = new System.Drawing.Size(0, 17);
            this.logdata_label.TabIndex = 19;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.ClientSize = new System.Drawing.Size(806, 451);
            this.Controls.Add(this.logdata_label);
            this.Controls.Add(this.selectTest);
            this.Controls.Add(this.i2cLabel);
            this.Controls.Add(this.voltageIO);
            this.Controls.Add(this.signalconversion);
            this.Controls.Add(this.auxIO);
            this.Controls.Add(this.multiCan);
            this.Controls.Add(this.highSpeed);
            this.Controls.Add(this.uart_label);
            this.Controls.Add(this.SingleWire2);
            this.Controls.Add(this.SingleWire1);
            this.Controls.Add(this.dallas);
            this.Controls.Add(this.button3);
            this.Controls.Add(this.log);
            this.Controls.Add(this.button2);
            this.Controls.Add(this.button1);
            this.Name = "Form1";
            this.Text = "Chimera Debug";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button button3;
        public System.Windows.Forms.TextBox Chimeralog;
        public System.Windows.Forms.Label dallas;
        public System.Windows.Forms.Label SingleWire1;
        public System.Windows.Forms.Label SingleWire2;
        public System.Windows.Forms.Label uart_label;
        public System.Windows.Forms.Label highSpeed;
        public System.Windows.Forms.Label multiCan;
        public System.Windows.Forms.Label auxIO;
        public System.Windows.Forms.Label signalconversion;
        public System.Windows.Forms.Label voltageIO;
        public System.Windows.Forms.Label i2cLabel;
        private System.Windows.Forms.Button selectTest;
        private System.Windows.Forms.Label logdata_label;
        public TextBox log;
    }
}

