namespace SmartDas.POPUP
{
    partial class POP_Login
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
            this.txtID = new System.Windows.Forms.TextBox();
            this.txtPWD = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.btnOK = new SmartDas.Components.MESButton();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.lblTitle = new SmartDas.Components.MESLabel();
            this.SuspendLayout();
            // 
            // txtID
            // 
            this.txtID.BackColor = System.Drawing.SystemColors.Window;
            this.txtID.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtID.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtID.Location = new System.Drawing.Point(160, 87);
            this.txtID.MaxLength = 20;
            this.txtID.Name = "txtID";
            this.txtID.Size = new System.Drawing.Size(318, 39);
            this.txtID.TabIndex = 0;
            this.txtID.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtID.Enter += new System.EventHandler(this.TextBox_Enter);
            this.txtID.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtID_KeyPress);
            this.txtID.Leave += new System.EventHandler(this.textBox_Leave);
            // 
            // txtPWD
            // 
            this.txtPWD.BackColor = System.Drawing.SystemColors.Window;
            this.txtPWD.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtPWD.ImeMode = System.Windows.Forms.ImeMode.Off;
            this.txtPWD.Location = new System.Drawing.Point(160, 147);
            this.txtPWD.MaxLength = 20;
            this.txtPWD.Name = "txtPWD";
            this.txtPWD.PasswordChar = '*';
            this.txtPWD.Size = new System.Drawing.Size(318, 39);
            this.txtPWD.TabIndex = 1;
            this.txtPWD.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.txtPWD.Enter += new System.EventHandler(this.TextBox_Enter);
            this.txtPWD.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtPWD_KeyPress);
            this.txtPWD.Leave += new System.EventHandler(this.textBox_Leave);
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label1.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(4, 87);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(144, 39);
            this.label1.TabIndex = 163;
            this.label1.Text = "관리자 ID";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // label2
            // 
            this.label2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(76)))), ((int)(((byte)(121)))), ((int)(((byte)(211)))));
            this.label2.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(4, 147);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(144, 39);
            this.label2.TabIndex = 164;
            this.label2.Text = "인증번호";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // btnOK
            // 
            this.btnOK.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnOK.BackColor = System.Drawing.Color.Transparent;
            this.btnOK.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnOK.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnOK.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnOK.ButtonPressed = false;
            this.btnOK.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnOK.DownPic = null;
            this.btnOK.ExTag = null;
            this.btnOK.Font = new System.Drawing.Font("맑은 고딕", 16F, System.Drawing.FontStyle.Bold);
            this.btnOK.FontSize = 16F;
            this.btnOK.LinkButtonBox = null;
            this.btnOK.LinkDatePicker = null;
            this.btnOK.LinkGrid = null;
            this.btnOK.LinkMoveSize = 0;
            this.btnOK.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnOK.Location = new System.Drawing.Point(160, 208);
            this.btnOK.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnOK.Name = "btnOK";
            this.btnOK.ParentBox = null;
            this.btnOK.Size = new System.Drawing.Size(148, 51);
            this.btnOK.TabIndex = 2;
            this.btnOK.Text = "확인";
            this.btnOK.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnOK.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnOK.UpPic = null;
            this.btnOK.UseFlag = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnCancel.BackColor = System.Drawing.Color.Transparent;
            this.btnCancel.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.btnCancel.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnCancel.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnCancel.ButtonPressed = false;
            this.btnCancel.ClickBackColor = System.Drawing.Color.Transparent;
            this.btnCancel.DownPic = null;
            this.btnCancel.ExTag = null;
            this.btnCancel.Font = new System.Drawing.Font("맑은 고딕", 16F, System.Drawing.FontStyle.Bold);
            this.btnCancel.FontSize = 16F;
            this.btnCancel.LinkButtonBox = null;
            this.btnCancel.LinkDatePicker = null;
            this.btnCancel.LinkGrid = null;
            this.btnCancel.LinkMoveSize = 0;
            this.btnCancel.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnCancel.Location = new System.Drawing.Point(330, 208);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(8, 9, 8, 9);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.ParentBox = null;
            this.btnCancel.Size = new System.Drawing.Size(148, 51);
            this.btnCancel.TabIndex = 3;
            this.btnCancel.Text = "닫기";
            this.btnCancel.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnCancel.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnCancel.UpPic = null;
            this.btnCancel.UseFlag = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // lblTitle
            // 
            this.lblTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.lblTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.lblTitle.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.lblTitle.ColorContent = System.Drawing.Color.Transparent;
            this.lblTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.lblTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.lblTitle.ForeColor = System.Drawing.Color.White;
            this.lblTitle.LabelPadding = new System.Drawing.Size(0, 0);
            this.lblTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTitle.Location = new System.Drawing.Point(4, 7);
            this.lblTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTitle.MoveControl = this;
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(476, 60);
            this.lblTitle.TabIndex = 86;
            this.lblTitle.Text = "인증확인";
            this.lblTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_Login
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(486, 272);
            this.ControlBox = false;
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.txtPWD);
            this.Controls.Add(this.txtID);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.lblTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "POP_Login";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Components.MESLabel lblTitle;
        private Components.MESButton btnCancel;
        private Components.MESButton btnOK;
        private System.Windows.Forms.TextBox txtID;
        private System.Windows.Forms.TextBox txtPWD;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
    }
}