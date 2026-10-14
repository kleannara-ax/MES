namespace SmartDas.POPUP
{
    partial class DAResultDate
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
            this.butPreMonth = new System.Windows.Forms.Button();
            this.butNextMonth = new System.Windows.Forms.Button();
            this.btnCancel = new SmartDas.Components.MESButton();
            this.btnOK = new SmartDas.Components.MESButton();
            this.mesLabelDate = new SmartDas.Components.MESLabel();
            this.mesMonthCalendar = new MESMonthCalendar();
            this.labTitle = new SmartDas.Components.MESLabel();
            this.buttonBox1 = new SmartDas.Components.ButtonBox();
            this.SuspendLayout();
            // 
            // butPreMonth
            // 
            this.butPreMonth.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(235)))), ((int)(((byte)(253)))));
            this.butPreMonth.CausesValidation = false;
            this.butPreMonth.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butPreMonth.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butPreMonth.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butPreMonth.Location = new System.Drawing.Point(22, 79);
            this.butPreMonth.Name = "butPreMonth";
            this.butPreMonth.Size = new System.Drawing.Size(62, 54);
            this.butPreMonth.TabIndex = 33;
            this.butPreMonth.Text = "◀";
            this.butPreMonth.UseVisualStyleBackColor = false;
            this.butPreMonth.Click += new System.EventHandler(this.butPreMonth_Click);
            // 
            // butNextMonth
            // 
            this.butNextMonth.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(223)))), ((int)(((byte)(235)))), ((int)(((byte)(253)))));
            this.butNextMonth.CausesValidation = false;
            this.butNextMonth.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(255)))), ((int)(((byte)(192)))), ((int)(((byte)(192)))));
            this.butNextMonth.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.butNextMonth.Font = new System.Drawing.Font("굴림", 11.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.butNextMonth.Location = new System.Drawing.Point(513, 79);
            this.butNextMonth.Name = "butNextMonth";
            this.butNextMonth.Size = new System.Drawing.Size(63, 54);
            this.butNextMonth.TabIndex = 34;
            this.butNextMonth.Text = "▶";
            this.butNextMonth.UseVisualStyleBackColor = false;
            this.butNextMonth.Click += new System.EventHandler(this.butNextMonth_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnCancel.BackColor = System.Drawing.Color.Transparent;
            this.btnCancel.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnCancel.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnCancel.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Change;
            this.btnCancel.ButtonPressed = false;
            this.btnCancel.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnCancel.DownPic = null;
            this.btnCancel.ExTag = null;
            this.btnCancel.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.btnCancel.FontSize = 24F;
            this.btnCancel.LinkButtonBox = null;
            this.btnCancel.LinkDatePicker = null;
            this.btnCancel.LinkGrid = null;
            this.btnCancel.LinkMoveSize = 0;
            this.btnCancel.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnCancel.Location = new System.Drawing.Point(419, 572);
            this.btnCancel.Margin = new System.Windows.Forms.Padding(0);
            this.btnCancel.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.ParentBox = null;
            this.btnCancel.Size = new System.Drawing.Size(165, 68);
            this.btnCancel.TabIndex = 217;
            this.btnCancel.Text = "닫기";
            this.btnCancel.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnCancel.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnCancel.UpPic = null;
            this.btnCancel.UseFlag = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // btnOK
            // 
            this.btnOK.AlarmColor = System.Drawing.Color.IndianRed;
            this.btnOK.BackColor = System.Drawing.Color.Transparent;
            this.btnOK.BackGradientStyle = Infragistics.Win.GradientStyle.None;
            this.btnOK.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnOK.ButtonClickType = SmartDas.Components.MESButton.ButtonClickTypeEnum.Change;
            this.btnOK.ButtonPressed = false;
            this.btnOK.ClickBackColor = System.Drawing.Color.Yellow;
            this.btnOK.DownPic = null;
            this.btnOK.ExTag = null;
            this.btnOK.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold);
            this.btnOK.FontSize = 24F;
            this.btnOK.LinkButtonBox = null;
            this.btnOK.LinkDatePicker = null;
            this.btnOK.LinkGrid = null;
            this.btnOK.LinkMoveSize = 0;
            this.btnOK.LinkType = SmartDas.Components.MESButton.LinkGridButtonType.Up;
            this.btnOK.Location = new System.Drawing.Point(8, 572);
            this.btnOK.Margin = new System.Windows.Forms.Padding(0);
            this.btnOK.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnOK.Name = "btnOK";
            this.btnOK.ParentBox = null;
            this.btnOK.Size = new System.Drawing.Size(165, 68);
            this.btnOK.TabIndex = 216;
            this.btnOK.Text = "확인";
            this.btnOK.TextHAlign = Infragistics.Win.HAlign.Center;
            this.btnOK.TextVAlign = Infragistics.Win.VAlign.Middle;
            this.btnOK.UpPic = null;
            this.btnOK.UseFlag = true;
            this.btnOK.Click += new System.EventHandler(this.btnOK_Click);
            // 
            // mesLabelDate
            // 
            this.mesLabelDate.BackColor = System.Drawing.Color.Black;
            this.mesLabelDate.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.mesLabelDate.ColorContent = System.Drawing.Color.Transparent;
            this.mesLabelDate.ColorLabel = System.Drawing.Color.Black;
            this.mesLabelDate.ColorReadOnly = System.Drawing.Color.Transparent;
            this.mesLabelDate.Font = new System.Drawing.Font("맑은 고딕", 27.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.mesLabelDate.ForeColor = System.Drawing.Color.White;
            this.mesLabelDate.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.mesLabelDate.Location = new System.Drawing.Point(183, 5);
            this.mesLabelDate.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.mesLabelDate.MoveControl = this;
            this.mesLabelDate.Name = "mesLabelDate";
            this.mesLabelDate.Size = new System.Drawing.Size(401, 53);
            this.mesLabelDate.TabIndex = 32;
            this.mesLabelDate.TextHAlign = Infragistics.Win.HAlign.Center;
            this.mesLabelDate.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // mesMonthCalendar
            // 
            this.mesMonthCalendar.Font = new System.Drawing.Font("맑은 고딕", 27.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.mesMonthCalendar.Location = new System.Drawing.Point(14, 70);
            this.mesMonthCalendar.MaxSelectionCount = 1;
            this.mesMonthCalendar.Name = "mesMonthCalendar";
            this.mesMonthCalendar.TabIndex = 31;
            this.mesMonthCalendar.TitleBackColor = System.Drawing.Color.RoyalBlue;
            this.mesMonthCalendar.TitleForeColor = System.Drawing.SystemColors.ControlLightLight;
            this.mesMonthCalendar.DoubleClickEx += new System.EventHandler(this.mesMonthCalendar_DoubleClickEx);
            this.mesMonthCalendar.DateChanged += new System.Windows.Forms.DateRangeEventHandler(this.mesMonthCalendar_DateChanged);
            this.mesMonthCalendar.MouseDown += new System.Windows.Forms.MouseEventHandler(this.mesMonthCalendar_MouseDown);
            // 
            // labTitle
            // 
            this.labTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.labTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.labTitle.ColorContent = System.Drawing.Color.Transparent;
            this.labTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.labTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.labTitle.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.labTitle.ForeColor = System.Drawing.Color.White;
            this.labTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.labTitle.Location = new System.Drawing.Point(8, 5);
            this.labTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.labTitle.MoveControl = this;
            this.labTitle.Name = "labTitle";
            this.labTitle.Size = new System.Drawing.Size(165, 53);
            this.labTitle.TabIndex = 4;
            this.labTitle.Text = "날짜 선택";
            this.labTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // buttonBox1
            // 
            this.buttonBox1.BackColor = System.Drawing.Color.Transparent;
            this.buttonBox1.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.buttonBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Buttons;
            this.buttonBox1.CountX = 4;
            this.buttonBox1.CountY = 4;
            this.buttonBox1.CurrentPage = 0;
            this.buttonBox1.ExTag = "";
            this.buttonBox1.Font = new System.Drawing.Font("맑은 고딕", 24F);
            this.buttonBox1.FontSize = 24F;
            this.buttonBox1.Location = new System.Drawing.Point(8, 64);
            this.buttonBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.buttonBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.buttonBox1.Name = "buttonBox1";
            this.buttonBox1.SelectCommand = null;
            this.buttonBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.buttonBox1.SelectProcedureName = null;
            this.buttonBox1.Size = new System.Drawing.Size(576, 499);
            this.buttonBox1.TabIndex = 0;
            // 
            // DAResultDate
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(595, 647);
            this.ControlBox = false;
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnOK);
            this.Controls.Add(this.butNextMonth);
            this.Controls.Add(this.butPreMonth);
            this.Controls.Add(this.mesLabelDate);
            this.Controls.Add(this.mesMonthCalendar);
            this.Controls.Add(this.labTitle);
            this.Controls.Add(this.buttonBox1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "DAResultDate";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.DAResultDate_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private Components.ButtonBox buttonBox1;
        private Components.MESLabel labTitle;
        private MESMonthCalendar mesMonthCalendar;
        private Components.MESLabel mesLabelDate;
        private System.Windows.Forms.Button butNextMonth;
        private System.Windows.Forms.Button butPreMonth;
        private Components.MESButton btnCancel;
        private Components.MESButton btnOK;
    }
}