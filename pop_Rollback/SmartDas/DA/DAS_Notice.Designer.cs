namespace SmartDas.DA
{
    partial class DAS_Notice
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
            Infragistics.Win.Appearance appearance1 = new Infragistics.Win.Appearance();
            Infragistics.Win.UltraWinSchedule.CalendarCombo.DateButton dateButton1 = new Infragistics.Win.UltraWinSchedule.CalendarCombo.DateButton();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(DAS_Notice));
            this.cboDate = new Infragistics.Win.UltraWinSchedule.UltraCalendarCombo();
            this.txtOPName = new SmartDas.Components.MESLabel();
            this.mesLabel2 = new SmartDas.Components.MESLabel();
            this.mesLabel1 = new SmartDas.Components.MESLabel();
            this.bBox1 = new SmartDas.Components.ButtonBox();
            this.grid_Notice = new SmartDas.Components.MESGrid();
            this.lblTitle = new SmartDas.Components.MESLabel();
            ((System.ComponentModel.ISupportInitialize)(this.cboDate)).BeginInit();
            this.SuspendLayout();
            // 
            // cboDate
            // 
            appearance1.FontData.BoldAsString = "True";
            appearance1.FontData.Name = "맑은 고딕";
            appearance1.FontData.SizeInPoints = 18F;
            this.cboDate.Appearance = appearance1;
            dateButton1.Date = new System.DateTime(2017, 4, 4, 17, 58, 55, 0);
            this.cboDate.DateButtons.Add(dateButton1);
            this.cboDate.Location = new System.Drawing.Point(612, 73);
            this.cboDate.Name = "cboDate";
            this.cboDate.NonAutoSizeHeight = 44;
            this.cboDate.Size = new System.Drawing.Size(243, 39);
            this.cboDate.TabIndex = 45;
            this.cboDate.Value = new System.DateTime(2017, 4, 4, 0, 0, 0, 0);
            // 
            // txtOPName
            // 
            this.txtOPName.BackColor = System.Drawing.Color.White;
            this.txtOPName.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.txtOPName.ColorContent = System.Drawing.Color.Transparent;
            this.txtOPName.ColorLabel = System.Drawing.Color.White;
            this.txtOPName.ColorReadOnly = System.Drawing.Color.Transparent;
            this.txtOPName.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.txtOPName.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.txtOPName.Location = new System.Drawing.Point(1028, 68);
            this.txtOPName.Margin = new System.Windows.Forms.Padding(0);
            this.txtOPName.MoveControl = null;
            this.txtOPName.Name = "txtOPName";
            this.txtOPName.Size = new System.Drawing.Size(247, 48);
            this.txtOPName.TabIndex = 44;
            this.txtOPName.TextHAlign = Infragistics.Win.HAlign.Center;
            this.txtOPName.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // mesLabel2
            // 
            this.mesLabel2.BackColor = System.Drawing.Color.RoyalBlue;
            this.mesLabel2.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.mesLabel2.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.mesLabel2.ColorContent = System.Drawing.Color.Transparent;
            this.mesLabel2.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.mesLabel2.ColorReadOnly = System.Drawing.Color.Transparent;
            this.mesLabel2.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.mesLabel2.ForeColor = System.Drawing.Color.White;
            this.mesLabel2.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.mesLabel2.Location = new System.Drawing.Point(863, 68);
            this.mesLabel2.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.mesLabel2.MoveControl = null;
            this.mesLabel2.Name = "mesLabel2";
            this.mesLabel2.Size = new System.Drawing.Size(160, 48);
            this.mesLabel2.TabIndex = 43;
            this.mesLabel2.Text = "공정";
            this.mesLabel2.TextHAlign = Infragistics.Win.HAlign.Center;
            this.mesLabel2.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // mesLabel1
            // 
            this.mesLabel1.BackColor = System.Drawing.Color.RoyalBlue;
            this.mesLabel1.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.mesLabel1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.mesLabel1.ColorContent = System.Drawing.Color.Transparent;
            this.mesLabel1.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.mesLabel1.ColorReadOnly = System.Drawing.Color.Transparent;
            this.mesLabel1.Font = new System.Drawing.Font("맑은 고딕", 18F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.mesLabel1.ForeColor = System.Drawing.Color.White;
            this.mesLabel1.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.mesLabel1.Location = new System.Drawing.Point(444, 68);
            this.mesLabel1.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.mesLabel1.MoveControl = null;
            this.mesLabel1.Name = "mesLabel1";
            this.mesLabel1.Size = new System.Drawing.Size(160, 48);
            this.mesLabel1.TabIndex = 42;
            this.mesLabel1.Text = "날짜";
            this.mesLabel1.TextHAlign = Infragistics.Win.HAlign.Center;
            this.mesLabel1.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // bBox1
            // 
            this.bBox1.BackColor = System.Drawing.Color.Transparent;
            this.bBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.bBox1.ButtonBoxType = SmartDas.Components.ButtonBox.ButtonBoxTypeEnum.Buttons;
            this.bBox1.CountX = 1;
            this.bBox1.CountY = 1;
            this.bBox1.CurrentPage = 0;
            this.bBox1.ExTag = "";
            this.bBox1.Font = new System.Drawing.Font("맑은 고딕", 25F, System.Drawing.FontStyle.Bold);
            this.bBox1.FontSize = 25F;
            this.bBox1.Location = new System.Drawing.Point(1107, 630);
            this.bBox1.MarginIn = new System.Windows.Forms.Padding(3);
            this.bBox1.MarginOut = new System.Windows.Forms.Padding(3);
            this.bBox1.Name = "bBox1";
            this.bBox1.SelectCommand = null;
            this.bBox1.SelectionMode = SmartDas.Components.ButtonBox.SelectionModeEnum.Single;
            this.bBox1.SelectProcedureName = null;
            this.bBox1.Size = new System.Drawing.Size(168, 95);
            this.bBox1.TabIndex = 41;
            this.bBox1.buttonClickEvent += new SmartDas.Components.ButtonBox.ButtonClick(this.bBox1_buttonClickEvent);
            // 
            // grid_Notice
            // 
            this.grid_Notice.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.grid_Notice.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.grid_Notice.CountRows = 0;
            this.grid_Notice.DataSource = null;
            this.grid_Notice.FixedCols = 0;
            this.grid_Notice.FontSize = 20.25F;
            this.grid_Notice.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.grid_Notice.HeaderFontSize = 13F;
            this.grid_Notice.HeadString = null;
            this.grid_Notice.Location = new System.Drawing.Point(5, 125);
            this.grid_Notice.Name = "grid_Notice";
            this.grid_Notice.Row = null;
            this.grid_Notice.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.grid_Notice.SelectCommand = null;
            this.grid_Notice.SelectProcedureName = null;
            this.grid_Notice.Size = new System.Drawing.Size(1270, 499);
            this.grid_Notice.TabIndex = 40;
            this.grid_Notice.VAlign = Infragistics.Win.VAlign.Middle;
            // 
            // lblTitle
            // 
            this.lblTitle.BackColor = System.Drawing.Color.RoyalBlue;
            this.lblTitle.BackGradientStyle = Infragistics.Win.GradientStyle.Default;
            this.lblTitle.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.lblTitle.ColorContent = System.Drawing.Color.Transparent;
            this.lblTitle.ColorLabel = System.Drawing.Color.RoyalBlue;
            this.lblTitle.ColorReadOnly = System.Drawing.Color.Transparent;
            this.lblTitle.Font = new System.Drawing.Font("맑은 고딕", 24F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.lblTitle.ForeColor = System.Drawing.Color.White;
            this.lblTitle.LabelType = SmartDas.Components.MESLabel.LabelTypeEnum.Label;
            this.lblTitle.Location = new System.Drawing.Point(5, 6);
            this.lblTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.lblTitle.MoveControl = null;
            this.lblTitle.Name = "lblTitle";
            this.lblTitle.Size = new System.Drawing.Size(1270, 56);
            this.lblTitle.TabIndex = 39;
            this.lblTitle.Text = "공지사항";
            this.lblTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.lblTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // DAS_Notice
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.ClientSize = new System.Drawing.Size(1280, 731);
            this.ControlBox = false;
            this.Controls.Add(this.cboDate);
            this.Controls.Add(this.txtOPName);
            this.Controls.Add(this.mesLabel2);
            this.Controls.Add(this.mesLabel1);
            this.Controls.Add(this.bBox1);
            this.Controls.Add(this.grid_Notice);
            this.Controls.Add(this.lblTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "DAS_Notice";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "DAS_Notice";
            this.Load += new System.EventHandler(this.DAS_Notice_Load);
            ((System.ComponentModel.ISupportInitialize)(this.cboDate)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private Infragistics.Win.UltraWinSchedule.UltraCalendarCombo cboDate;
        private Components.MESLabel txtOPName;
        private Components.MESLabel mesLabel2;
        private Components.MESLabel mesLabel1;
        private Components.ButtonBox bBox1;
        private Components.MESGrid grid_Notice;
        private Components.MESLabel lblTitle;
    }
}