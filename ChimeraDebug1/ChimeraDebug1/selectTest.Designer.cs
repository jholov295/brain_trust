namespace ChimeraDebug1
{
    partial class selectTest
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
            this.label1 = new System.Windows.Forms.Label();
            this.dallas = new System.Windows.Forms.CheckBox();
            this.singleWire1 = new System.Windows.Forms.CheckBox();
            this.singleWire2 = new System.Windows.Forms.CheckBox();
            this.uartProto = new System.Windows.Forms.CheckBox();
            this.hsCAN = new System.Windows.Forms.CheckBox();
            this.multiCAN = new System.Windows.Forms.CheckBox();
            this.auxIO = new System.Windows.Forms.CheckBox();
            this.sigConv = new System.Windows.Forms.CheckBox();
            this.voltageIO = new System.Windows.Forms.CheckBox();
            this.i2c = new System.Windows.Forms.CheckBox();
            this.label2 = new System.Windows.Forms.Label();
            this.button1 = new System.Windows.Forms.Button();
            this.button2 = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(160, 9);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(117, 24);
            this.label1.TabIndex = 0;
            this.label1.Text = "Select Tests ";
            // 
            // dallas
            // 
            this.dallas.AutoSize = true;
            this.dallas.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dallas.Location = new System.Drawing.Point(100, 76);
            this.dallas.Name = "dallas";
            this.dallas.Size = new System.Drawing.Size(66, 20);
            this.dallas.TabIndex = 1;
            this.dallas.Text = "Dallas";
            this.dallas.UseVisualStyleBackColor = true;
            this.dallas.CheckedChanged += new System.EventHandler(this.checkBox1_CheckedChanged);
            // 
            // singleWire1
            // 
            this.singleWire1.AutoSize = true;
            this.singleWire1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.singleWire1.Location = new System.Drawing.Point(100, 114);
            this.singleWire1.Name = "singleWire1";
            this.singleWire1.Size = new System.Drawing.Size(100, 20);
            this.singleWire1.TabIndex = 2;
            this.singleWire1.Text = "SingleWire1";
            this.singleWire1.UseVisualStyleBackColor = true;
            this.singleWire1.CheckedChanged += new System.EventHandler(this.checkBox2_CheckedChanged);
            // 
            // singleWire2
            // 
            this.singleWire2.AutoSize = true;
            this.singleWire2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.singleWire2.Location = new System.Drawing.Point(100, 159);
            this.singleWire2.Name = "singleWire2";
            this.singleWire2.Size = new System.Drawing.Size(100, 20);
            this.singleWire2.TabIndex = 3;
            this.singleWire2.Text = "SingleWire2";
            this.singleWire2.UseVisualStyleBackColor = true;
            this.singleWire2.CheckedChanged += new System.EventHandler(this.checkBox3_CheckedChanged);
            // 
            // uartProto
            // 
            this.uartProto.AutoSize = true;
            this.uartProto.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.uartProto.Location = new System.Drawing.Point(100, 204);
            this.uartProto.Name = "uartProto";
            this.uartProto.Size = new System.Drawing.Size(125, 20);
            this.uartProto.TabIndex = 4;
            this.uartProto.Text = "UART Protocols";
            this.uartProto.UseVisualStyleBackColor = true;
            this.uartProto.CheckedChanged += new System.EventHandler(this.checkBox4_CheckedChanged);
            // 
            // hsCAN
            // 
            this.hsCAN.AutoSize = true;
            this.hsCAN.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.hsCAN.Location = new System.Drawing.Point(100, 251);
            this.hsCAN.Name = "hsCAN";
            this.hsCAN.Size = new System.Drawing.Size(143, 20);
            this.hsCAN.TabIndex = 5;
            this.hsCAN.Text = "Dedicated HS CAN";
            this.hsCAN.UseVisualStyleBackColor = true;
            this.hsCAN.CheckedChanged += new System.EventHandler(this.checkBox5_CheckedChanged);
            // 
            // multiCAN
            // 
            this.multiCAN.AutoSize = true;
            this.multiCAN.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.multiCAN.Location = new System.Drawing.Point(262, 76);
            this.multiCAN.Name = "multiCAN";
            this.multiCAN.Size = new System.Drawing.Size(126, 20);
            this.multiCAN.TabIndex = 6;
            this.multiCAN.Text = "Multiplexed CAN";
            this.multiCAN.UseVisualStyleBackColor = true;
            this.multiCAN.CheckedChanged += new System.EventHandler(this.checkBox6_CheckedChanged);
            // 
            // auxIO
            // 
            this.auxIO.AutoSize = true;
            this.auxIO.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.auxIO.Location = new System.Drawing.Point(262, 114);
            this.auxIO.Name = "auxIO";
            this.auxIO.Size = new System.Drawing.Size(65, 20);
            this.auxIO.TabIndex = 7;
            this.auxIO.Text = "Aux IO";
            this.auxIO.UseVisualStyleBackColor = true;
            this.auxIO.CheckedChanged += new System.EventHandler(this.checkBox7_CheckedChanged);
            // 
            // sigConv
            // 
            this.sigConv.AutoSize = true;
            this.sigConv.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.sigConv.Location = new System.Drawing.Point(262, 159);
            this.sigConv.Name = "sigConv";
            this.sigConv.Size = new System.Drawing.Size(136, 20);
            this.sigConv.TabIndex = 8;
            this.sigConv.Text = "Signal Conversion";
            this.sigConv.UseVisualStyleBackColor = true;
            this.sigConv.CheckedChanged += new System.EventHandler(this.checkBox8_CheckedChanged);
            // 
            // voltageIO
            // 
            this.voltageIO.AutoSize = true;
            this.voltageIO.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.voltageIO.Location = new System.Drawing.Point(262, 204);
            this.voltageIO.Name = "voltageIO";
            this.voltageIO.Size = new System.Drawing.Size(90, 20);
            this.voltageIO.TabIndex = 9;
            this.voltageIO.Text = "Voltage IO";
            this.voltageIO.UseVisualStyleBackColor = true;
            this.voltageIO.CheckedChanged += new System.EventHandler(this.checkBox9_CheckedChanged);
            // 
            // i2c
            // 
            this.i2c.AutoSize = true;
            this.i2c.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.i2c.Location = new System.Drawing.Point(262, 251);
            this.i2c.Name = "i2c";
            this.i2c.Size = new System.Drawing.Size(46, 20);
            this.i2c.TabIndex = 10;
            this.i2c.Text = "I2C";
            this.i2c.UseVisualStyleBackColor = true;
            this.i2c.CheckedChanged += new System.EventHandler(this.checkBox10_CheckedChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(6, 42);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(459, 13);
            this.label2.TabIndex = 11;
            this.label2.Text = "Note: Selecting certain tests might cause others to run beforehand if needed for " +
    "that test to pass";
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(100, 289);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(100, 43);
            this.button1.TabIndex = 12;
            this.button1.Text = "Start";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(262, 289);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(97, 43);
            this.button2.TabIndex = 13;
            this.button2.Text = "Cancel";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.Click += new System.EventHandler(this.button2_Click);
            // 
            // selectTest
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.ClientSize = new System.Drawing.Size(477, 353);
            this.Controls.Add(this.button2);
            this.Controls.Add(this.button1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.i2c);
            this.Controls.Add(this.voltageIO);
            this.Controls.Add(this.sigConv);
            this.Controls.Add(this.auxIO);
            this.Controls.Add(this.multiCAN);
            this.Controls.Add(this.hsCAN);
            this.Controls.Add(this.uartProto);
            this.Controls.Add(this.singleWire2);
            this.Controls.Add(this.singleWire1);
            this.Controls.Add(this.dallas);
            this.Controls.Add(this.label1);
            this.Name = "selectTest";
            this.Text = "selectTest";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.CheckBox dallas;
        private System.Windows.Forms.CheckBox singleWire1;
        private System.Windows.Forms.CheckBox singleWire2;
        private System.Windows.Forms.CheckBox uartProto;
        private System.Windows.Forms.CheckBox hsCAN;
        private System.Windows.Forms.CheckBox multiCAN;
        private System.Windows.Forms.CheckBox auxIO;
        private System.Windows.Forms.CheckBox sigConv;
        private System.Windows.Forms.CheckBox voltageIO;
        private System.Windows.Forms.CheckBox i2c;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Button button2;
    }
}