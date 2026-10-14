namespace SmartDas.POPUP
{
    partial class POP_WRK92
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
            this.label7 = new System.Windows.Forms.Label();
            this.dtpSendDate = new System.Windows.Forms.DateTimePicker();
            this.lbllblMEndChkName = new System.Windows.Forms.Label();
            this.lblTitle = new System.Windows.Forms.Label();
            this.butStartDate = new System.Windows.Forms.Button();
            this.chkMonth = new SmartDas.Components.MESLabel();
            this.btnClose = new SmartDas.Components.MESButton();
            this.btnConfirm = new SmartDas.Components.MESButton();
            this.labTitle = new SmartDas.Components.MESLabel();
            this.SuspendLayout();
            // 
            // label7
            // 
            this.label7.BackColor = System.Drawing.Color.Gray;
            this.label7.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.label7.ForeColor = System.Drawing.Color.White;
            this.label7.Location = new System.Drawing.Point(62, 149);
            this.label7.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label7.MinimumSize = new System.Drawing.Size(0, 46);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(187, 60);
            this.label7.TabIndex = 158;
            this.label7.Text = "전송일자";
            this.label7.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // dtpSendDate
            // 
            this.dtpSendDate.CalendarFont = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpSendDate.CustomFormat = "yyyy-MM-dd";
            this.dtpSendDate.Font = new System.Drawing.Font("맑은 고딕", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.dtpSendDate.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
            this.dtpSendDate.ImeMode = System.Windows.Forms.ImeMode.NoControl;
            this.dtpSendDate.Location = new System.Drawing.Point(256, 149);
            this.dtpSendDate.MinimumSize = new System.Drawing.Size(4, 46);
            this.dtpSendDate.Name = "dtpSendDate";
            this.dtpSendDate.ShowUpDown = true;
            this.dtpSendDate.Size = new System.Drawing.Size(331, 46);
            this.dtpSendDate.TabIndex = 159;
            // 
            // lbllblMEndChkName
            // 
            this.lbllblMEndChkName.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lbllblMEndChkName.Location = new System.Drawing.Point(112, 215);
            this.lbllblMEndChkName.Name = "lbllblMEndChkName";
            this.lbllblMEndChkName.Size = new System.Drawing.Size(103, 40);
            this.lbllblMEndChkName.TabIndex = 205;
            this.lbllblMEndChkName.Text = "월 선택";
            this.lbllblMEndChkName.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // lblTitle
            // 
            this.lblTitle.BackColor = System.Drawing.Color.Gray;
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTitle.ForeColor = System.Drawing.Color.White;
            this.lblTitle.Location = new System.Drawing.Point(62, 90);
            this.lblTitle.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(525, 50);
            this.lblTitle.TabIndex = 206;
            this.lblTitle.Text = "선택된 로그파일을 전송합니다.";
            this.lblTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // butStartDate
            // 
            this.butStartDate.BackgroundImage = global::SmartDas.Properties.Resources.Calendar;
            this.butStartDate.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center;
            this.butStartDate.CausesValidation = false;
            this.butStartDate.FlatAppearance.BorderSize = 0;
            this.butStartDate.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butStartDate.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butStartDate.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butStartDate.Location = new System.Drawing.Point(506, 153);
            this.butStartDate.Name = "butStartDate";
            this.butStartDate.Size = new System.Drawing.Size(46, 42);
            this.butStartDate.TabIndex = 221;
            this.butStartDate.UseVisualStyleBackColor = false;
            this.butStartDate.Click += new System.EventHandler(this.butStartDate_Click);
            // 
            // chkMonth
            // 
            this.chkMonth.BackColor = System.Drawing.Color.White;
            this.chkMonth.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.chkMonth.ColorContent = System.Drawing.Color.Transparent;
            this.chkMonth.ColorLabel = System.Drawing.Color.White;
            this.chkMonth.ColorReadOnly = System.Drawing.Color.Transparent;
            this.chkMonth.Font = new System.Drawing.Font("맑은 고딕", 15.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.chkMonth.LabelPadding = new System.Drawing.Size(0, 0);
            this.chkMonth.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.chkMonth.Location = new System.Drawing.Point(67, 215);
            this.chkMonth.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.chkMonth.MoveControl = null;
            this.chkMonth.Name = "chkMonth";
            this.chkMonth.Size = new System.Drawing.Size(40, 40);
            this.chkMonth.TabIndex = 204;
            this.chkMonth.Text = "V";
            this.chkMonth.TextHAlign = Infragistics.Win.HAlign.Center;
            this.chkMonth.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.chkMonth.Click += new System.EventHandler(this.chkMonth_Click);
            // 
            // btnClose
            // 
            this.btnClose.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnClose.BackColor = System.Drawing.Color.Transparent;
            this.btnClose.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnClose.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnClose.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnClose.ButtonPressed = false;
            this.btnClose.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnClose.DownPic = null;
            this.btnClose.ExTag = null;
            this.btnClose.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnClose.FontSize = 14F;
            this.btnClose.LinkButtonBox = null;
            this.btnClose.LinkDatePicker = null;
            this.btnClose.LinkGrid = null;
            this.btnClose.LinkMoveSize = 0;
            this.btnClose.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnClose.Location = new System.Drawing.Point(406, 282);
            this.btnClose.Margin = new System.Windows.Forms.Padding(0);
            this.btnClose.MaximumSize = new System.Drawing.Size(375, 375);
            this.btnClose.Name = "btnClose";
            this.btnClose.ParentBox = null;
            this.btnClose.Size = new System.Drawing.Size(181, 111);
            this.btnClose.TabIndex = 156;
            this.btnClose.Text = "닫기";
            this.btnClose.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnClose.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnClose.UpPic = null;
            this.btnClose.UseFlag = true;
            this.btnClose.Click += new System.EventHandler(this.btnClose_Click);
            // 
            // btnConfirm
            // 
            this.btnConfirm.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnConfirm.BackColor = System.Drawing.Color.Transparent;
            this.btnConfirm.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnConfirm.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnConfirm.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Click;
            this.btnConfirm.ButtonPressed = false;
            this.btnConfirm.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnConfirm.DownPic = null;
            this.btnConfirm.ExTag = null;
            this.btnConfirm.Font = new System.Drawing.Font("맑은 고딕", 14F, System.Drawing.FontStyle.Bold);
            this.btnConfirm.FontSize = 14F;
            this.btnConfirm.LinkButtonBox = null;
            this.btnConfirm.LinkDatePicker = null;
            this.btnConfirm.LinkGrid = null;
            this.btnConfirm.LinkMoveSize = 0;
            this.btnConfirm.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnConfirm.Location = new System.Drawing.Point(58, 282);
            this.btnConfirm.Margin = new System.Windows.Forms.Padding(0);
            this.btnConfirm.MaximumSize = new System.Drawing.Size(375, 375);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.ParentBox = null;
            this.btnConfirm.Size = new System.Drawing.Size(181, 111);
            this.btnConfirm.TabIndex = 154;
            this.btnConfirm.Text = "전송";
            this.btnConfirm.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnConfirm.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnConfirm.UpPic = null;
            this.btnConfirm.UseFlag = true;
            this.btnConfirm.Click += new System.EventHandler(this.btnConfirm_Click);
            // 
            // labTitle
            // 
            this.labTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.labTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.labTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.labTitle.ColorContent = System.Drawing.Color.Transparent;
            this.labTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.labTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.labTitle.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.labTitle.ForeColor = System.Drawing.Color.White;
            this.labTitle.LabelPadding = new System.Drawing.Size(0, 0);
            this.labTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.labTitle.Location = new System.Drawing.Point(58, 8);
            this.labTitle.Margin = new System.Windows.Forms.Padding(6, 8, 6, 8);
            this.labTitle.MoveControl = this;
            this.labTitle.Name = "labTitle";
            this.labTitle.Size = new System.Drawing.Size(529, 74);
            this.labTitle.TabIndex = 4;
            this.labTitle.Text = "LOG 파일 전송";
            this.labTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_WRK92
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(120F, 120F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(646, 407);
            this.ControlBox = false;
            this.Controls.Add(this.butStartDate);
            this.Controls.Add(this.lblTitle);
            this.Controls.Add(this.lbllblMEndChkName);
            this.Controls.Add(this.chkMonth);
            this.Controls.Add(this.dtpSendDate);
            this.Controls.Add(this.label7);
            this.Controls.Add(this.btnClose);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.labTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "POP_WRK92";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.POP_WRK92_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private Components.MESLabel labTitle;
        private Components.MESButton btnClose;
        private Components.MESButton btnConfirm;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.DateTimePicker dtpSendDate;
        private System.Windows.Forms.Label lbllblMEndChkName;
        private Components.MESLabel chkMonth;
        private System.Windows.Forms.Label lblTitle;
        private System.Windows.Forms.Button butStartDate;
    }
}