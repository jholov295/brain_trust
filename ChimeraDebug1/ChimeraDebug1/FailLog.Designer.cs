namespace ChimeraDebug1
{
    partial class FailLog
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
            this.label2 = new System.Windows.Forms.Label();
            this.yes_button1 = new System.Windows.Forms.Button();
            this.no_button2 = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.DarkRed;
            this.label1.Location = new System.Drawing.Point(123, 36);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(194, 25);
            this.label1.TabIndex = 0;
            this.label1.Text = "Debug Tests Failed!!";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(82, 83);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(285, 20);
            this.label2.TabIndex = 1;
            this.label2.Text = "Would you like to write to Rich Data?";
            // 
            // yes_button1
            // 
            this.yes_button1.Location = new System.Drawing.Point(66, 138);
            this.yes_button1.Name = "yes_button1";
            this.yes_button1.Size = new System.Drawing.Size(129, 53);
            this.yes_button1.TabIndex = 2;
            this.yes_button1.Text = "Yes";
            this.yes_button1.UseVisualStyleBackColor = true;
            this.yes_button1.Click += new System.EventHandler(this.yes_button1_Click);
            // 
            // no_button2
            // 
            this.no_button2.Location = new System.Drawing.Point(254, 138);
            this.no_button2.Name = "no_button2";
            this.no_button2.Size = new System.Drawing.Size(129, 53);
            this.no_button2.TabIndex = 3;
            this.no_button2.Text = "No";
            this.no_button2.UseVisualStyleBackColor = true;
            this.no_button2.Click += new System.EventHandler(this.no_button2_Click);
            // 
            // FailLog
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.ClientSize = new System.Drawing.Size(486, 215);
            this.Controls.Add(this.no_button2);
            this.Controls.Add(this.yes_button1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Name = "FailLog";
            this.Text = "FailLog";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button yes_button1;
        private System.Windows.Forms.Button no_button2;
    }
}