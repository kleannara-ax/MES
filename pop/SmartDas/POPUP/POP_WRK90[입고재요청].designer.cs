namespace SmartDas.POPUP
{
    partial class POP_WRK90
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(POP_WRK90));
            this.Grid1 = new SmartDas.Components.MESGrid();
            this.btnClose = new SmartDas.Components.MESButton();
            this.btnConfirm = new SmartDas.Components.MESButton();
            this.labTitle = new SmartDas.Components.MESLabel();
            this.SuspendLayout();
            // 
            // Grid1
            // 
            this.Grid1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.Grid1.CellClickActionType = Infragistics.Win.UltraWinGrid.CellClickAction.RowSelect;
            this.Grid1.CountRows = 0;
            this.Grid1.DataSource = null;
            this.Grid1.FixedCols = 0;
            this.Grid1.Font = new System.Drawing.Font("맑은 고딕", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(129)));
            this.Grid1.FontSize = 20.25F;
            this.Grid1.GridAutoFitStyle = Infragistics.Win.UltraWinGrid.AutoFitStyle.None;
            this.Grid1.HeaderFontSize = 13F;
            this.Grid1.HeadString = null;
            this.Grid1.Location = new System.Drawing.Point(9, 74);
            this.Grid1.Name = "Grid1";
            this.Grid1.Row = null;
            this.Grid1.ScrollBar = Infragistics.Win.UltraWinGrid.Scrollbars.None;
            this.Grid1.SelectCommand = null;
            this.Grid1.SelectProcedureName = null;
            this.Grid1.Size = new System.Drawing.Size(1155, 357);
            this.Grid1.TabIndex = 157;
            this.Grid1.VAlign = Infragistics.Win.VAlign.Middle;
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
            this.btnClose.Location = new System.Drawing.Point(1017, 440);
            this.btnClose.Margin = new System.Windows.Forms.Padding(0);
            this.btnClose.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnClose.Name = "btnClose";
            this.btnClose.ParentBox = null;
            this.btnClose.Size = new System.Drawing.Size(145, 89);
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
            this.btnConfirm.Location = new System.Drawing.Point(9, 440);
            this.btnConfirm.Margin = new System.Windows.Forms.Padding(0);
            this.btnConfirm.MaximumSize = new System.Drawing.Size(300, 300);
            this.btnConfirm.Name = "btnConfirm";
            this.btnConfirm.ParentBox = null;
            this.btnConfirm.Size = new System.Drawing.Size(145, 89);
            this.btnConfirm.TabIndex = 154;
            this.btnConfirm.Text = "재전송";
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
            this.labTitle.Location = new System.Drawing.Point(9, 6);
            this.labTitle.Margin = new System.Windows.Forms.Padding(5, 6, 5, 6);
            this.labTitle.MoveControl = this;
            this.labTitle.Name = "labTitle";
            this.labTitle.Size = new System.Drawing.Size(1153, 59);
            this.labTitle.TabIndex = 4;
            this.labTitle.Text = "입고요청 재전송";
            this.labTitle.TextHAlign = Infragistics.Win.HAlign.Center;
            this.labTitle.TextVAlign = Infragistics.Win.VAlign.Middle;
            // 
            // POP_WRK90
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            this.BackColor = System.Drawing.Color.WhiteSmoke;
            this.ClientSize = new System.Drawing.Size(1176, 536);
            this.ControlBox = false;
            this.Controls.Add(this.Grid1);
            this.Controls.Add(this.btnClose);
            this.Controls.Add(this.btnConfirm);
            this.Controls.Add(this.labTitle);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Name = "POP_WRK90";
            this.ShowIcon = false;
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.POP_WRK90_Load);
            this.ResumeLayout(false);

        }

        #endregion

        private Components.MESLabel labTitle;
        private Components.MESButton btnClose;
        private Components.MESButton btnConfirm;
        private Components.MESGrid Grid1;
    }
}